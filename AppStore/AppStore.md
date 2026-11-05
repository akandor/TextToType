# TextToType: App Store Connect metadata

Copy each field into App Store Connect → your app → macOS App → version 1.0.
Character limits are noted in brackets; every field below is within its limit.

---

## App Information

**Name** [30]
```
TextToType: Type Clipboard
```

**Subtitle** [30]
```
Paste where paste won't work
```

**Bundle ID:** `com.toepper.rocks.TextToType`
**SKU:** `texttotype-mac`
**Primary category:** Utilities
**Secondary category:** Productivity
**Content rights:** Does not contain third-party content
**Age rating:** 4+ (answer "None" to every question)

---

## Version 1.0

**Promotional text** [170]
```
Remote desktop, VM or a login form that blocks paste? Press one shortcut and TextToType types your clipboard for you, keystroke by keystroke.
```

**Description** [4000]
```
TextToType types the text on your clipboard into any app, exactly as if you were typing it on your keyboard.

Some places just won't let you paste: remote desktops, virtual machines, VNC and Citrix sessions, server consoles, installers, and web forms that block pasting passwords or codes. TextToType gets around that. Copy your text, click where it should go, and press your shortcut.

HOW IT WORKS
• Copy any text.
• Click into the window where it should go.
• Press your shortcut (default ⌃⌥⌘V) and TextToType types it for you.
• Press the shortcut again at any time to stop.

FEATURES
• Real keystrokes: uses your current keyboard layout's actual keys, including Shift and Option characters, so remote machines and VMs receive what you'd type yourself.
• Any shortcut you like: record your own global keyboard shortcut.
• Adjustable typing speed: slow it down for remote sessions that drop characters, or let it fly.
• Stays out of your way: lives quietly in the menu bar, with no Dock icon.
• Launch at login: always ready when you need it.
• Unicode-aware: emoji and special characters that need more than one key on your keyboard are typed too.

PRIVATE BY DESIGN
TextToType reads your clipboard only when you press the shortcut or choose Type Clipboard from the menu. Nothing is stored, logged or sent anywhere, and the app makes no network connections at all.

FREE AND OPEN SOURCE
TextToType is open source under the MIT license. You can read every line of code, report issues or contribute on GitHub: github.com/akandor/TextToType

PERMISSION
To send keystrokes to other apps, macOS asks you to allow TextToType once in System Settings → Privacy & Security → Accessibility. TextToType uses this permission only to type your clipboard when you ask it to.
```

**Keywords** [100]
```
paste,clipboard,typer,keystroke,remote desktop,vm,vnc,citrix,autotype,keyboard,typing,password
```

**What's New in This Version** [4000]
```
First release. Type your clipboard anywhere with a single shortcut.
```

**Support URL** (required)
```
https://github.com/akandor/TextToType/issues
```

**Marketing URL** (optional)
```
https://github.com/akandor/TextToType
```

**Copyright**
```
© 2026 Armin Toepper
```

---

## App Privacy

**Privacy Policy URL** (required)
```
https://github.com/akandor/TextToType/blob/main/PRIVACY.md
```
The same text is below and in [PRIVACY.md](../PRIVACY.md).

**Data collection:** choose **"No, we do not collect data from this app."** The result is the label *Data Not Collected*.

### Privacy policy text

```
TextToType Privacy Policy
Last updated: November 5, 2026

TextToType does not collect, store, or share any personal data.

• Clipboard: TextToType reads the text on your clipboard only at the moment you press your shortcut or choose "Type Clipboard". The text is typed into the app you have in front and is not saved, logged or transmitted.
• Accessibility permission: used solely to send keystrokes to the app you are typing into.
• Network: TextToType makes no network connections.
• Analytics and tracking: none.
• Settings (your shortcut and typing speed) are stored locally on your Mac.

Questions: https://github.com/akandor/TextToType/issues
```

---

## App Review Information

**Sign-in required:** No

**Notes for the reviewer**
```
TextToType is a menu bar utility (no Dock icon). It types the current clipboard text into the frontmost app using simulated key events, for places where paste is blocked (remote desktop clients, virtual machines, VNC/Citrix sessions, web forms that block paste).

How to test:
1. Launch TextToType. Its keyboard icon appears in the menu bar and the Settings window opens.
2. Click "Grant Access…" and allow TextToType under System Settings → Privacy & Security → Accessibility. The app uses CGRequestPostEventAccess / CGEventPost only, solely to post the keystrokes for the clipboard text.
3. Copy some text, open TextEdit, click into a document and press ⌃⌥⌘V (or choose "Type Clipboard" from the menu bar icon). The text is typed character by character.
4. Press the shortcut again to stop typing mid-way.

The clipboard is only read when the user triggers typing. No data is stored or transmitted, and the app has no network access.

TextToType is open source (MIT): https://github.com/akandor/TextToType
```

---

## Screenshots

macOS screenshots must be 16:10. Files in `AppStore/Screenshots/` are 2880 × 1800:

| File | Shows |
| --- | --- |
| `01-type-anywhere.png` | Hero image: menu bar menu and text being typed into a remote session |
| `02-settings.png` | Settings: shortcut, typing speed, clipboard clearing, launch at login |

The sources are HTML files in `AppStore/screenshot-src/`. To re-render after editing one, run this from the project folder:

```bash
"/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" --headless=new --hide-scrollbars --force-device-scale-factor=2 --window-size=1440,900 --screenshot="$PWD/AppStore/Screenshots/01-type-anywhere.png" "file://$PWD/AppStore/screenshot-src/01-type-anywhere.html"
```
