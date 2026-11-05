import Carbon.HIToolbox
import CoreGraphics

/// A modifier key held down while pressing a key.
enum Modifier: CaseIterable {
    case control, shift, option, rightOption

    var keyCode: CGKeyCode {
        switch self {
        case .control: CGKeyCode(kVK_Control)
        case .shift: CGKeyCode(kVK_Shift)
        case .option: CGKeyCode(kVK_Option)
        case .rightOption: CGKeyCode(kVK_RightOption)
        }
    }

    /// Event flags including the device-dependent bit (left/right key), so remote desktop
    /// and VM clients that look at it can tell e.g. right Option (AltGr) from left Option.
    var flags: CGEventFlags {
        switch self {
        case .control: [.maskControl, CGEventFlags(rawValue: UInt64(NX_DEVICELCTLKEYMASK))]
        case .shift: [.maskShift, CGEventFlags(rawValue: UInt64(NX_DEVICELSHIFTKEYMASK))]
        case .option: [.maskAlternate, CGEventFlags(rawValue: UInt64(NX_DEVICELALTKEYMASK))]
        case .rightOption: [.maskAlternate, CGEventFlags(rawValue: UInt64(NX_DEVICERALTKEYMASK))]
        }
    }
}

/// A physical key press: virtual key code plus the modifiers needed to produce a character.
struct KeyStroke {
    let keyCode: CGKeyCode
    /// Pressed in this order, released in reverse.
    let modifiers: [Modifier]

    /// AltGr on Windows: Ctrl + right Alt. Windows treats Ctrl+Alt as AltGr, and clients that
    /// pass right Alt through as AltGr get that too.
    static func altGr(_ keyCode: CGKeyCode, shift: Bool = false) -> KeyStroke {
        KeyStroke(keyCode: keyCode, modifiers: [.control, .rightOption] + (shift ? [.shift] : []))
    }
}

/// Helpers around the user's current keyboard layout.
/// Call from the main thread (Text Input Sources APIs are main-thread only).
enum KeyboardLayout {
    /// Keypad keys are skipped so digits/operators map to the main keyboard row.
    private static let keypadKeyCodes: Set<Int> = [
        kVK_ANSI_KeypadDecimal, kVK_ANSI_KeypadMultiply, kVK_ANSI_KeypadPlus, kVK_ANSI_KeypadClear,
        kVK_ANSI_KeypadDivide, kVK_ANSI_KeypadEnter, kVK_ANSI_KeypadMinus, kVK_ANSI_KeypadEquals,
        kVK_ANSI_Keypad0, kVK_ANSI_Keypad1, kVK_ANSI_Keypad2, kVK_ANSI_Keypad3, kVK_ANSI_Keypad4,
        kVK_ANSI_Keypad5, kVK_ANSI_Keypad6, kVK_ANSI_Keypad7, kVK_ANSI_Keypad8, kVK_ANSI_Keypad9,
    ]

    /// Keys that only exist on Japanese (JIS) keyboards. Skipped for Windows, where PC keyboards lack them.
    private static let jisKeyCodes: Set<Int> = [kVK_JIS_Yen, kVK_JIS_Underscore, kVK_JIS_KeypadComma, kVK_JIS_Eisu, kVK_JIS_Kana]

    /// Builds a map of every character that can be typed with a single key combination.
    ///
    /// - `.mac`: the current layout with no modifier, ⇧, ⌥ or ⇧⌥, preferring the simplest combination.
    /// - `.windows`: the Windows (PC) version of the current layout: its unmodified and ⇧ layers,
    ///   plus its AltGr layer typed as Ctrl + right Alt. The Mac ⌥ layer is not used, because the
    ///   remote side reads ⌥ as plain Alt (e.g. ⌥L for @ on a German Mac is Alt+L on Windows).
    /// - `.unicode`: only space; everything else is sent as Unicode text (Return/Tab are always keys).
    static func characterMap(for target: TargetSystem) -> [Character: KeyStroke] {
        switch target {
        case .mac: macCharacterMap()
        case .windows: windowsCharacterMap()
        // Space is the same key everywhere; everything else is typed as Unicode.
        case .unicode: [" ": KeyStroke(keyCode: CGKeyCode(kVK_Space), modifiers: [])]
        }
    }

    private static func macCharacterMap() -> [Character: KeyStroke] {
        let combos: [(carbon: UInt32, modifiers: [Modifier])] = [
            (0, []),
            (UInt32(shiftKey), [.shift]),
            (UInt32(optionKey), [.option]),
            (UInt32(shiftKey | optionKey), [.shift, .option]),
        ]
        return withLayout(id: nil) { layout in
            var map: [Character: KeyStroke] = [:]
            for combo in combos {
                for (code, character) in characters(layout, modifiers: combo.carbon).sorted(by: { $0.key < $1.key })
                where map[character] == nil {
                    map[character] = KeyStroke(keyCode: CGKeyCode(code), modifiers: combo.modifiers)
                }
            }
            return map
        } ?? [:]
    }

    private static func windowsCharacterMap() -> [Character: KeyStroke] {
        let pc = PCLayout.forLayout(id: currentLayoutID())
        return withLayout(id: pc.baseLayoutID) { layout in
            let base = characters(layout, modifiers: 0, skipping: jisKeyCodes)
            var layers = [false: base, true: characters(layout, modifiers: UInt32(shiftKey), skipping: jisKeyCodes)]

            func code(for key: PCLayout.Key) -> Int? {
                switch key {
                case .code(let code): code
                case .base(let character): base.filter { $0.value == character }.keys.min()
                }
            }

            // Keys where the Windows layout differs from the macOS one.
            for change in pc.changes {
                guard let code = code(for: change.key) else { continue }
                layers[change.shifted]![code] = change.character
            }

            var map: [Character: KeyStroke] = [:]
            for shifted in [false, true] {
                for (code, character) in layers[shifted]!.sorted(by: { $0.key < $1.key }) where map[character] == nil {
                    map[character] = KeyStroke(keyCode: CGKeyCode(code), modifiers: shifted ? [.shift] : [])
                }
            }
            for (shifted, entries) in [(false, pc.altGr), (true, pc.shiftAltGr)] {
                for (key, character) in entries where map[character] == nil {
                    guard let code = code(for: key) else { continue }
                    map[character] = .altGr(CGKeyCode(code), shift: shifted)
                }
            }
            return map
        } ?? [:]
    }

    /// Printable single characters produced by each key (by key code) with the given modifiers.
    private static func characters(
        _ layout: UnsafePointer<UCKeyboardLayout>,
        modifiers: UInt32,
        skipping skipped: Set<Int> = []
    ) -> [Int: Character] {
        var result: [Int: Character] = [:]
        for code in 0..<128 where !keypadKeyCodes.contains(code) && !skipped.contains(code) {
            guard let string = translate(layout, keyCode: UInt16(code), modifiers: modifiers),
                  string.count == 1,
                  let character = string.first,
                  let scalar = character.unicodeScalars.first,
                  scalar.value >= 0x20, scalar.value != 0x7F
            else { continue }
            result[code] = character
        }
        return result
    }

    /// Human-readable name of a key for display in shortcuts.
    static func keyName(for keyCode: UInt16) -> String {
        if let name = specialKeyNames[Int(keyCode)] { return name }
        if let string = withLayout(id: nil, { translate($0, keyCode: keyCode, modifiers: 0) }) ?? nil,
           !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return string.uppercased()
        }
        return String(localized: "Key \(keyCode)", comment: "Shortcut display for a key without a name")
    }

    private static let specialKeyNames: [Int: String] = [
        kVK_Return: "↩", kVK_Tab: "⇥", kVK_Space: String(localized: "Space", comment: "Name of the space bar in shortcuts"), kVK_Delete: "⌫", kVK_ForwardDelete: "⌦",
        kVK_Escape: "⎋", kVK_LeftArrow: "←", kVK_RightArrow: "→", kVK_UpArrow: "↑", kVK_DownArrow: "↓",
        kVK_Home: "↖", kVK_End: "↘", kVK_PageUp: "⇞", kVK_PageDown: "⇟", kVK_ANSI_KeypadEnter: "⌤",
        kVK_F1: "F1", kVK_F2: "F2", kVK_F3: "F3", kVK_F4: "F4", kVK_F5: "F5", kVK_F6: "F6",
        kVK_F7: "F7", kVK_F8: "F8", kVK_F9: "F9", kVK_F10: "F10", kVK_F11: "F11", kVK_F12: "F12",
        kVK_F13: "F13", kVK_F14: "F14", kVK_F15: "F15", kVK_F16: "F16", kVK_F17: "F17",
        kVK_F18: "F18", kVK_F19: "F19", kVK_F20: "F20",
    ]

    // MARK: Private

    /// Input source ID of the current keyboard layout, e.g. `com.apple.keylayout.German`.
    private static func currentLayoutID() -> String? {
        guard let source = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
              let raw = TISGetInputSourceProperty(source, kTISPropertyInputSourceID)
        else { return nil }
        return Unmanaged<CFString>.fromOpaque(raw).takeUnretainedValue() as String
    }

    /// Runs `body` with the layout data of the given installed layout, or the current one if `id` is nil
    /// (or not installed).
    private static func withLayout<T>(id: String?, _ body: (UnsafePointer<UCKeyboardLayout>) -> T) -> T? {
        var sources: [TISInputSource?] = []
        if let id {
            let filter = [kTISPropertyInputSourceID as String: id] as CFDictionary
            let list = TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource]
            sources.append(list?.first)
        }
        sources += [
            TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
            TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue(),
        ]
        for case let source? in sources {
            guard let raw = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else { continue }
            let data = Unmanaged<CFData>.fromOpaque(raw).takeUnretainedValue()
            guard let bytes = CFDataGetBytePtr(data) else { continue }
            return bytes.withMemoryRebound(to: UCKeyboardLayout.self, capacity: 1) { body($0) }
        }
        return nil
    }

    /// Returns the character(s) a key produces, or nil for dead keys / non-printing keys.
    private static func translate(
        _ layout: UnsafePointer<UCKeyboardLayout>,
        keyCode: UInt16,
        modifiers: UInt32
    ) -> String? {
        var deadKeyState: UInt32 = 0
        var length = 0
        var chars = [UniChar](repeating: 0, count: 4)
        let status = UCKeyTranslate(
            layout,
            keyCode,
            UInt16(kUCKeyActionDown),
            (modifiers >> 8) & 0xFF,
            UInt32(LMGetKbdType()),
            0,
            &deadKeyState,
            chars.count,
            &length,
            &chars
        )
        // deadKeyState != 0 means this is a dead key (e.g. ⌥E for ´) — not directly typeable.
        guard status == noErr, deadKeyState == 0, length > 0 else { return nil }
        return String(utf16CodeUnits: chars, count: length)
    }
}
