import Carbon.HIToolbox
import CoreGraphics

/// A physical key press: virtual key code plus the modifiers needed to produce a character.
struct KeyStroke {
    let keyCode: CGKeyCode
    let flags: CGEventFlags
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

    /// Builds a map of every character the current layout can produce with
    /// no modifier, ⇧, ⌥ or ⇧⌥ — preferring the simplest combination.
    static func characterMap() -> [Character: KeyStroke] {
        let combos: [(carbon: UInt32, flags: CGEventFlags)] = [
            (0, []),
            (UInt32(shiftKey), .maskShift),
            (UInt32(optionKey), .maskAlternate),
            (UInt32(shiftKey | optionKey), [.maskShift, .maskAlternate]),
        ]

        return withLayout { layout in
            var map: [Character: KeyStroke] = [:]
            for combo in combos {
                for code in 0..<128 where !keypadKeyCodes.contains(code) {
                    guard let string = translate(layout, keyCode: UInt16(code), modifiers: combo.carbon),
                          string.count == 1,
                          let character = string.first,
                          map[character] == nil,
                          let scalar = character.unicodeScalars.first,
                          scalar.value >= 0x20, scalar.value != 0x7F
                    else { continue }
                    map[character] = KeyStroke(keyCode: CGKeyCode(code), flags: combo.flags)
                }
            }
            return map
        } ?? [:]
    }

    /// Human-readable name of a key for display in shortcuts.
    static func keyName(for keyCode: UInt16) -> String {
        if let name = specialKeyNames[Int(keyCode)] { return name }
        if let string = withLayout({ translate($0, keyCode: keyCode, modifiers: 0) }) ?? nil,
           !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return string.uppercased()
        }
        return "Key \(keyCode)"
    }

    private static let specialKeyNames: [Int: String] = [
        kVK_Return: "↩", kVK_Tab: "⇥", kVK_Space: "Space", kVK_Delete: "⌫", kVK_ForwardDelete: "⌦",
        kVK_Escape: "⎋", kVK_LeftArrow: "←", kVK_RightArrow: "→", kVK_UpArrow: "↑", kVK_DownArrow: "↓",
        kVK_Home: "↖", kVK_End: "↘", kVK_PageUp: "⇞", kVK_PageDown: "⇟", kVK_ANSI_KeypadEnter: "⌤",
        kVK_F1: "F1", kVK_F2: "F2", kVK_F3: "F3", kVK_F4: "F4", kVK_F5: "F5", kVK_F6: "F6",
        kVK_F7: "F7", kVK_F8: "F8", kVK_F9: "F9", kVK_F10: "F10", kVK_F11: "F11", kVK_F12: "F12",
        kVK_F13: "F13", kVK_F14: "F14", kVK_F15: "F15", kVK_F16: "F16", kVK_F17: "F17",
        kVK_F18: "F18", kVK_F19: "F19", kVK_F20: "F20",
    ]

    // MARK: Private

    private static func withLayout<T>(_ body: (UnsafePointer<UCKeyboardLayout>) -> T) -> T? {
        let sources = [
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
