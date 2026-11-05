# TextToType

![TextToType](AppStore/Screenshots/01-type-anywhere.png)

A tiny, free and open source macOS menu bar app that **types your clipboard** with real keystrokes, which is handy where paste doesn't work: remote desktops, VMs, VNC/Citrix sessions, server and installer consoles, and web forms that block paste.

- Global shortcut you can change (default **⌃⌥⌘V**). Press it again to stop typing.
- Uses your current keyboard layout's real key codes (including ⇧/⌥ combinations). Characters that can't be reached with a single key fall back to Unicode input.
- Adjustable delay per key, for remote sessions that drop characters.
- Lives in the menu bar and can launch at login.
- Sandboxed, with no network access and no data collection (see [PRIVACY.md](PRIVACY.md)).

## Usage

1. Copy some text.
2. Click into the window where it should be typed.
3. Press your shortcut (default ⌃⌥⌘V). Press it again to stop.

## Build

Requirements: macOS 14+, Xcode 26+ (the app icon is an Icon Composer `.icon` file).

Open `TextToType.xcodeproj` in Xcode and press Run. The project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen); after editing `project.yml`, run `xcodegen generate`.

To build it yourself, change `DEVELOPMENT_TEAM` and `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml` (or under *Signing & Capabilities* in Xcode) to your own.

## Permissions

Typing needs **Accessibility** access: System Settings → Privacy & Security → Accessibility → enable TextToType.

> macOS ties the Accessibility grant to the app's signature. Debug builds (Apple Development) and release builds count as different apps. If the switch is on but typing doesn't work, remove TextToType from the list with − and add the copy you're running again.

For launch at login, put the app in `/Applications` first, then turn on **Launch at login** from the menu or Settings.

## Project layout

| Path | Contents |
| --- | --- |
| `TextToType/` | App source (SwiftUI + AppKit) |
| `TextToType/Typer.swift` | Posts the keyboard events |
| `TextToType/KeyboardLayout.swift` | Maps characters to keys on the current layout |
| `TextToType/HotKeyManager.swift` | Global shortcut (Carbon `RegisterEventHotKey`) |
| `AppStore/` | App Store metadata, screenshots and their HTML sources |

## Contributing

Issues and pull requests are welcome: https://github.com/akandor/TextToType/issues

## License

[MIT](LICENSE) © 2026 Armin Toepper

Keyboard icon from [Font Awesome Free](https://fontawesome.com) ([CC BY 4.0](https://fontawesome.com/license/free)).
