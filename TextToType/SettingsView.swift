import AppKit
import Carbon.HIToolbox
import ServiceManagement
import SwiftUI

final class SettingsWindowController: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    func show() {
        if window == nil {
            let window = NSWindow(contentViewController: makeTabs())
            window.styleMask = [.titled, .closable]
            window.toolbarStyle = .preference
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.center()
            self.window = window
        }

        // Menu bar (accessory) apps can't reliably take focus. Become a regular app while
        // Settings is open (Dock icon + ⌘-Tab), and defer until the menu has closed.
        DispatchQueue.main.async { [weak self] in
            guard let window = self?.window else { return }
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            window.orderFrontRegardless()
        }
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    /// Toolbar tabs like in Apple's apps; the window resizes to each tab's content.
    private func makeTabs() -> NSTabViewController {
        let tabs = NSTabViewController()
        tabs.tabStyle = .toolbar
        tabs.transitionOptions = [.allowUserInteraction]

        func add(_ title: String, symbol: String, _ view: some View) {
            let hosting = NSHostingController(rootView: view.environmentObject(AppState.shared))
            hosting.sizingOptions = .preferredContentSize
            hosting.title = title // shown as the window title while the tab is selected
            let item = NSTabViewItem(viewController: hosting)
            item.label = title
            item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: title)
            tabs.addTabViewItem(item)
        }

        add(String(localized: "General"), symbol: "gearshape", GeneralSettingsView())
        add(String(localized: "Typing"), symbol: "keyboard", TypingSettingsView())
        add(String(localized: "Permissions"), symbol: "lock.shield", PermissionsSettingsView())
        add(String(localized: "About"), symbol: "info.circle", AboutSettingsView())
        return tabs
    }
}

/// Common look of the settings tabs.
private struct SettingsPane<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        Form { content }
            .formStyle(.grouped)
            .frame(width: 460)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        SettingsPane {
            Section {
                LabeledContent("Shortcut") {
                    ShortcutRecorder(shortcut: $state.shortcut) { recording in
                        if recording { state.suspendHotKey() } else { state.registerHotKey() }
                    }
                }
                if let error = state.hotKeyError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                Text("Press the shortcut to type the clipboard into the focused app. Press it again to stop.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Picker("Language", selection: $state.language) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(verbatim: language.title).tag(language)
                    }
                }
                if state.language != state.launchLanguage {
                    HStack {
                        Text("Restart TextToType to use the new language.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Spacer()
                        Button("Restart Now") { state.restart() }
                    }
                }
                Toggle("Launch at login", isOn: Binding(
                    get: { state.launchAtLogin },
                    set: { state.setLaunchAtLogin($0) }
                ))
                if state.launchAtLoginNeedsApproval {
                    HStack {
                        Text("Needs approval in System Settings.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Spacer()
                        Button("Open Login Items…") { SMAppService.openSystemSettingsLoginItems() }
                    }
                }
                if let error = state.launchAtLoginError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
        }
    }
}

struct TypingSettingsView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        SettingsPane {
            Section {
                Picker("Type for", selection: $state.targetSystem) {
                    ForEach(TargetSystem.allCases) { target in
                        Text(target.title).tag(target)
                    }
                }
                Text(state.targetSystem.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                LabeledContent("Delay per key") {
                    HStack {
                        Slider(value: $state.keyDelayMs, in: 0...100, step: 1)
                        Text("\(Int(state.keyDelayMs)) ms")
                            .monospacedDigit()
                            .frame(width: 50, alignment: .trailing)
                    }
                }
                Text("Increase this if the target app (e.g. a remote desktop or VM) drops characters.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Picker("Clear clipboard after typing", selection: $state.clipboardClearing) {
                    ForEach(ClipboardClearing.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                Text("“Only passwords” clears text that a password manager marked as a password. The clipboard is left alone if you copied something else while typing, or if you stopped typing early.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct PermissionsSettingsView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        SettingsPane {
            Section {
                HStack {
                    Image(systemName: state.hasAccessibility ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(state.hasAccessibility ? .green : .orange)
                    Text(state.hasAccessibility
                         ? "Accessibility access granted"
                         : "Accessibility access is required to type")
                    Spacer()
                    if !state.hasAccessibility {
                        Button("Grant Access…") { state.requestAccessibility() }
                    }
                }
                if !state.hasAccessibility {
                    Text("Already turned on in System Settings? That entry is from an older build. Remove it with − and add this app again.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { state.refreshStatus() }
    }
}

struct AboutSettingsView: View {
    static let repositoryURL = URL(string: "https://github.com/akandor/TextToType")!
    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)
            Text(verbatim: "TextToType")
                .font(.title2.bold())
            Text("Version \(Self.appVersion)")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("TextToType is free and open source.")
                .padding(.top, 4)
            Link(destination: Self.repositoryURL) {
                Label("View on GitHub", systemImage: "arrow.up.right.square")
            }
        }
        .padding(.vertical, 28)
        .frame(width: 460)
    }
}

/// Click, then press a key combination to set it as the shortcut.
struct ShortcutRecorder: View {
    @Binding var shortcut: Shortcut?
    var onRecordingChange: (Bool) -> Void = { _ in }

    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack(spacing: 6) {
            Button(action: toggleRecording) {
                Text(isRecording
                     ? String(localized: "Press shortcut…")
                     : shortcut?.displayString ?? String(localized: "Record Shortcut"))
                    .frame(minWidth: 120)
            }
            .help(isRecording ? "Press Esc to cancel" : "Click to record a new shortcut")

            if shortcut != nil, !isRecording {
                Button {
                    shortcut = nil
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .help("Clear shortcut")
            }
        }
        .onDisappear(perform: stopRecording)
    }

    private func toggleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    private func startRecording() {
        isRecording = true
        onRecordingChange(true)
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handle(event)
            return nil
        }
    }

    private func stopRecording() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        if isRecording {
            isRecording = false
            onRecordingChange(false)
        }
    }

    private func handle(_ event: NSEvent) {
        let mods = event.modifierFlags.intersection([.command, .option, .control, .shift])

        if event.keyCode == UInt16(kVK_Escape), mods.isEmpty {
            stopRecording()
            return
        }

        // Require ⌘, ⌥ or ⌃ (plain or ⇧-only keys would break normal typing) — F-keys are fine alone.
        let hasRealModifier = !mods.intersection([.command, .option, .control]).isEmpty
        guard hasRealModifier || Shortcut.isFunctionKey(event.keyCode) else {
            NSSound.beep()
            return
        }

        shortcut = Shortcut(keyCode: event.keyCode, modifierFlags: mods.rawValue)
        stopRecording()
    }
}
