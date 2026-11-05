import AppKit
import Carbon.HIToolbox
import ServiceManagement

/// When to clear the clipboard after the whole text has been typed.
enum ClipboardClearing: String, CaseIterable, Identifiable {
    case never
    /// Only text a password manager marked as concealed (`org.nspasteboard.ConcealedType`).
    case passwords
    case always

    var id: String { rawValue }

    var title: String {
        switch self {
        case .never: String(localized: "Never")
        case .passwords: String(localized: "Only passwords")
        case .always: String(localized: "Always")
        }
    }
}

extension NSPasteboard.PasteboardType {
    /// Set by password managers (KeePassXC, 1Password, …) on secrets they copy. See nspasteboard.org.
    static let concealed = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")
}

/// Central app state: settings, global hotkey, typing jobs, permissions.
final class AppState: ObservableObject {
    static let shared = AppState()

    private enum Keys {
        static let shortcut = "shortcut"
        static let keyDelay = "keyDelayMs"
        static let clipboardClearing = "clipboardClearing"
    }

    @Published var shortcut: Shortcut? {
        didSet {
            saveShortcut()
            registerHotKey()
        }
    }

    /// Pause between typed characters, in milliseconds.
    @Published var keyDelayMs: Double {
        didSet { defaults.set(keyDelayMs, forKey: Keys.keyDelay) }
    }

    @Published var clipboardClearing: ClipboardClearing {
        didSet { defaults.set(clipboardClearing.rawValue, forKey: Keys.clipboardClearing) }
    }

    @Published private(set) var isTyping = false
    @Published private(set) var hotKeyError: String?
    @Published private(set) var launchAtLogin = false
    @Published private(set) var launchAtLoginNeedsApproval = false
    @Published private(set) var launchAtLoginError: String?
    @Published private(set) var hasAccessibility = false

    private let defaults = UserDefaults.standard
    private let hotKeys = HotKeyManager()
    private var job: TypingJob?
    private var statusTimer: Timer?

    private init() {
        if let data = defaults.data(forKey: Keys.shortcut) {
            shortcut = try? JSONDecoder().decode(Shortcut.self, from: data)
        } else {
            shortcut = .default
        }
        keyDelayMs = defaults.object(forKey: Keys.keyDelay) as? Double ?? 10
        clipboardClearing = defaults.string(forKey: Keys.clipboardClearing)
            .flatMap(ClipboardClearing.init(rawValue:)) ?? .passwords

        hotKeys.onPress = { [weak self] in self?.toggleTyping(fromHotKey: true) }
        registerHotKey()
        refreshStatus()

        // Keep permission / login-item status fresh (e.g. after the user flips it in System Settings).
        statusTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.refreshStatus()
        }
    }

    // MARK: Typing

    func toggleTyping(fromHotKey: Bool) {
        if let job {
            job.cancel()
            self.job = nil
            isTyping = false
            return
        }

        refreshStatus()
        guard hasAccessibility else {
            showAccessibilityAlert()
            return
        }
        let pasteboard = NSPasteboard.general
        guard let text = pasteboard.string(forType: .string), !text.isEmpty else {
            NSSound.beep()
            return
        }
        let changeCount = pasteboard.changeCount
        let isConcealed = pasteboard.types?.contains(.concealed) ?? false

        let job = TypingJob()
        self.job = job
        isTyping = true
        // From the menu, give the previously focused app a moment to regain focus.
        Typer.start(
            text: text,
            keyDelay: keyDelayMs / 1000,
            startDelay: fromHotKey ? 0.1 : 0.4,
            job: job
        ) { [weak self] in
            guard let self else { return }
            if !job.isCancelled {
                self.clearClipboardAfterTyping(changeCount: changeCount, isConcealed: isConcealed)
            }
            guard self.job === job else { return }
            self.job = nil
            self.isTyping = false
        }
    }

    /// Clears the clipboard per the user's setting, unless something new was copied while typing.
    private func clearClipboardAfterTyping(changeCount: Int, isConcealed: Bool) {
        let shouldClear: Bool
        switch clipboardClearing {
        case .never: shouldClear = false
        case .passwords: shouldClear = isConcealed
        case .always: shouldClear = true
        }
        let pasteboard = NSPasteboard.general
        guard shouldClear, pasteboard.changeCount == changeCount else { return }
        pasteboard.clearContents()
    }

    // MARK: Hotkey

    func registerHotKey() {
        hotKeyError = nil
        guard let shortcut else {
            hotKeys.unregister()
            return
        }
        let status = hotKeys.register(shortcut)
        if status == OSStatus(eventHotKeyExistsErr) {
            hotKeyError = String(localized: "That shortcut is already used by another app.")
        } else if status != noErr {
            hotKeyError = String(localized: "Couldn't register the shortcut (error \(status)).")
        }
    }

    /// Temporarily disable the hotkey (while recording a new one).
    func suspendHotKey() {
        hotKeys.unregister()
    }

    private func saveShortcut() {
        let data = shortcut.flatMap { try? JSONEncoder().encode($0) } ?? Data()
        defaults.set(data, forKey: Keys.shortcut)
    }

    // MARK: Permissions & login item

    func refreshStatus() {
        let access = AXIsProcessTrusted() || CGPreflightPostEventAccess()
        if access != hasAccessibility { hasAccessibility = access }

        let status = SMAppService.mainApp.status
        let enabled = status == .enabled
        let needsApproval = status == .requiresApproval
        if enabled != launchAtLogin { launchAtLogin = enabled }
        if needsApproval != launchAtLoginNeedsApproval { launchAtLoginNeedsApproval = needsApproval }
    }

    func requestAccessibility() {
        // Shows the system prompt the first time; afterwards just open the settings pane.
        if !CGRequestPostEventAccess() {
            openAccessibilitySettings()
        }
        refreshStatus()
    }

    /// Explains the missing permission instead of silently jumping to System Settings.
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = String(localized: "TextToType needs Accessibility access")
        alert.informativeText = String(localized: """
        Turn on TextToType in System Settings → Privacy & Security → Accessibility.

        If it's already turned on there, that entry belongs to an older build of the app. \
        Select it, remove it with the − button, then add this copy again (or turn it on when prompted).
        """)
        alert.addButton(withTitle: String(localized: "Open System Settings"))
        alert.addButton(withTitle: String(localized: "Cancel"))
        NSApp.activate()
        if alert.runModal() == .alertFirstButtonReturn {
            requestAccessibility()
        }
    }

    func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        launchAtLoginError = nil
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            launchAtLoginError = error.localizedDescription
        }
        refreshStatus()
    }
}
