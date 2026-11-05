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

/// The system that receives the keystrokes. Remote desktop and VM clients send physical keys,
/// so characters must be typed with the key combination the remote system's layout expects.
enum TargetSystem: String, CaseIterable, Identifiable {
    case mac
    /// Windows PC (e.g. via Remote Desktop or a VM): AltGr instead of ⌥.
    case windows
    /// Every character sent as text (Unicode) instead of key presses, independent of the layout.
    case unicode

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mac: String(localized: "Mac")
        case .windows: String(localized: "Windows PC")
        case .unicode: String(localized: "Any system (Unicode)")
        }
    }

    var detail: String {
        switch self {
        case .mac:
            String(localized: "Presses the keys of your Mac keyboard layout. For Mac apps and remote Macs.")
        case .windows:
            String(localized: "Types characters on the AltGr layer, like @ on a German keyboard, the Windows way. For Windows over Remote Desktop or in a VM.")
        case .unicode:
            String(localized: "Sends each character as text instead of a key press, so the keyboard layout doesn't matter. Works in Mac apps and in remote clients that pass text on. VMs, consoles and installer screens may type nothing or wrong letters.")
        }
    }
}

/// Language of the app's UI. Stored as the app's own `AppleLanguages` default,
/// which macOS reads at launch, so a change takes effect after a restart.
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = ""
    case english = "en"
    case german = "de"
    case french = "fr"
    case italian = "it"
    case spanish = "es"
    case portugueseBrazil = "pt-BR"

    var id: String { rawValue }

    /// Languages are shown in their own language, so they can be found from any UI language.
    var title: String {
        switch self {
        case .system: String(localized: "System default")
        case .english: "English"
        case .german: "Deutsch"
        case .french: "Français"
        case .italian: "Italiano"
        case .spanish: "Español"
        case .portugueseBrazil: "Português (Brasil)"
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
        static let targetSystem = "targetSystem"
        static let appleLanguages = "AppleLanguages"
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

    @Published var targetSystem: TargetSystem {
        didSet { defaults.set(targetSystem.rawValue, forKey: Keys.targetSystem) }
    }

    @Published var language: AppLanguage {
        didSet {
            if language == .system {
                defaults.removeObject(forKey: Keys.appleLanguages)
            } else {
                defaults.set([language.rawValue], forKey: Keys.appleLanguages)
            }
        }
    }

    /// The language the running app was started with. A different `language` needs a restart.
    let launchLanguage: AppLanguage

    /// Launch argument for the new instance started by `restart()`.
    private static let relaunchArgument = "--relaunched"
    static var wasRelaunched: Bool { CommandLine.arguments.contains(relaunchArgument) }

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
        targetSystem = defaults.string(forKey: Keys.targetSystem)
            .flatMap(TargetSystem.init(rawValue:)) ?? .unicode
        // Only the app's own domain: `defaults.array` would also return the system-wide languages.
        let appDomain = Bundle.main.bundleIdentifier.flatMap(UserDefaults.standard.persistentDomain(forName:))
        let storedLanguage = (appDomain?[Keys.appleLanguages] as? [String])?.first
            .flatMap(AppLanguage.init(rawValue:)) ?? .system
        language = storedLanguage
        launchLanguage = storedLanguage

        hotKeys.onPress = { [weak self] in self?.toggleTyping(fromHotKey: true) }
        if Self.wasRelaunched {
            registerHotKeyAfterPreviousInstanceQuits()
        } else {
            registerHotKey()
        }
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
            target: targetSystem,
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

    /// After `restart()`, the old instance may still hold the shortcut for a moment.
    private func registerHotKeyAfterPreviousInstanceQuits(deadline: Date = Date().addingTimeInterval(5)) {
        let me = ProcessInfo.processInfo.processIdentifier
        let others = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier ?? "")
            .filter { $0.processIdentifier != me && !$0.isTerminated }
        if others.isEmpty || Date() > deadline {
            registerHotKey()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.registerHotKeyAfterPreviousInstanceQuits(deadline: deadline)
            }
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

    /// Starts a new instance (which reopens Settings) and quits this one, e.g. to apply a new language.
    func restart() {
        job?.cancel()
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        configuration.arguments = [Self.relaunchArgument]
        NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: configuration) { _, error in
            DispatchQueue.main.async {
                if error == nil { NSApp.terminate(nil) } else { NSSound.beep() }
            }
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
