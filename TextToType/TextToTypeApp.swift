import SwiftUI

@main
struct TextToTypeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var state = AppState.shared

    var body: some Scene {
        MenuBarExtra {
            MenuContent()
                .environmentObject(state)
        } label: {
            Image(nsImage: Self.menuBarImage(named: state.isTyping ? "MenuBarIconTyping" : "MenuBarIcon"))
        }
    }

    /// Asset SVGs are 640pt; scale to menu bar size and keep them as templates (adapts to light/dark).
    private static func menuBarImage(named name: String) -> NSImage {
        guard let source = NSImage(named: name), let image = source.copy() as? NSImage else {
            return NSImage(systemSymbolName: "keyboard", accessibilityDescription: "TextToType")!
        }
        image.size = NSSize(width: 20, height: 20)
        image.isTemplate = true
        image.accessibilityDescription = "TextToType"
        return image
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let firstLaunchKey = "hasLaunchedBefore"

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = AppState.shared
        if !UserDefaults.standard.bool(forKey: firstLaunchKey) {
            UserDefaults.standard.set(true, forKey: firstLaunchKey)
            SettingsWindowController.shared.show()
        }
    }

    /// Opening the app again (Finder, Spotlight) while it's running shows Settings.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        SettingsWindowController.shared.show()
        return true
    }
}

struct MenuContent: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        if state.isTyping {
            Button("Stop Typing") { state.toggleTyping(fromHotKey: false) }
        } else {
            Button(typeTitle) { state.toggleTyping(fromHotKey: false) }
        }

        if !state.hasAccessibility {
            Button("⚠️ Grant Accessibility Access…") { state.requestAccessibility() }
        }

        Picker("Type for", selection: $state.targetSystem) {
            ForEach(TargetSystem.allCases) { target in
                Text(target.title).tag(target)
            }
        }

        Divider()

        Toggle("Launch at Login", isOn: Binding(
            get: { state.launchAtLogin },
            set: { state.setLaunchAtLogin($0) }
        ))
        Button("Settings…") { SettingsWindowController.shared.show() }
            .keyboardShortcut(",")

        Divider()

        Button("Quit TextToType") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }

    private var typeTitle: String {
        if let shortcut = state.shortcut {
            return String(localized: "Type Clipboard") + "   " + shortcut.displayString
        }
        return String(localized: "Type Clipboard")
    }
}
