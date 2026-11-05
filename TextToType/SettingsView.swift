import AppKit
import Carbon.HIToolbox
import ServiceManagement
import SwiftUI

final class SettingsWindowController: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    func show() {
        if window == nil {
            let hosting = NSHostingController(rootView: SettingsView().environmentObject(AppState.shared))
            let window = NSWindow(contentViewController: hosting)
            window.title = String(localized: "TextToType Settings")
            window.styleMask = [.titled, .closable]
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
}

struct SettingsView: View {
    @EnvironmentObject private var state: AppState

    static let repositoryURL = URL(string: "https://github.com/akandor/TextToType")!
    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    var body: some View {
        Form {
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

            Section("Typing") {
                Picker("Type for", selection: $state.targetSystem) {
                    ForEach(TargetSystem.allCases) { target in
                        Text(target.title).tag(target)
                    }
                }
                Text(state.targetSystem.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)

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

                Picker("Clear clipboard after typing", selection: $state.clipboardClearing) {
                    ForEach(ClipboardClearing.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                Text("“Only passwords” clears text that a password manager marked as a password. The clipboard is left alone if you copied something else while typing, or if you stopped typing early.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("General") {
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

            Section("Permissions") {
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

            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TextToType is free and open source.")
                        Text("Version \(Self.appVersion)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Link(destination: Self.repositoryURL) {
                        Label("View on GitHub", systemImage: "arrow.up.right.square")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear { state.refreshStatus() }
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
