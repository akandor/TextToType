import Carbon.HIToolbox

/// How the Windows (PC) version of a keyboard layout differs from the macOS one.
///
/// Remote desktop and VM clients send physical keys, and the remote system applies its own
/// layout. The unmodified and ⇧ layers mostly match between macOS and Windows, but the
/// ⌥ layer doesn't: Windows uses AltGr instead (e.g. @ is ⌥L on a German Mac but AltGr+Q on Windows).
///
/// Keys are named by the character they type unmodified on the macOS layout, so their position
/// doesn't depend on the keyboard type (ANSI/ISO). Dead keys have no character and use a key code.
struct PCLayout {
    enum Key {
        /// The key that types this character with no modifier on the macOS layout.
        case base(Character)
        case code(Int)
    }

    struct Change {
        let key: Key
        let shifted: Bool
        /// nil if the key types nothing (or a dead key) on Windows.
        let character: Character?
    }

    /// Installed macOS layout whose unmodified and ⇧ layers match the Windows layout.
    /// nil means the current layout.
    var baseLayoutID: String?
    /// Unmodified / ⇧ characters that differ between the macOS base layout and Windows.
    var changes: [Change] = []
    var altGr: [(Key, Character)] = []
    var shiftAltGr: [(Key, Character)] = []

    /// The Windows layout for a macOS layout ID. Unknown layouts use the macOS layout's
    /// unmodified and ⇧ layers only; everything else is typed as Unicode.
    static func forLayout(id: String?) -> PCLayout {
        guard let id, id.hasPrefix(prefix) else { return PCLayout() }
        return layouts[String(id.dropFirst(prefix.count))] ?? PCLayout()
    }

    private static let prefix = "com.apple.keylayout."

    // Shorthands for dead keys, which have no base character.
    private static let leftBracketKey = Key.code(kVK_ANSI_LeftBracket)  // right of P
    private static let rightBracketKey = Key.code(kVK_ANSI_RightBracket) // right of that
    private static let quoteKey = Key.code(kVK_ANSI_Quote)              // 2nd right of L
    private static let backslashKey = Key.code(kVK_ANSI_Backslash)      // 3rd right of L
    private static let equalKey = Key.code(kVK_ANSI_Equal)              // 2nd right of 0

    private static let german = PCLayout(altGr: [
        (.base("q"), "@"), (.base("e"), "€"), (.base("m"), "µ"), (.base("2"), "²"), (.base("3"), "³"),
        (.base("7"), "{"), (.base("8"), "["), (.base("9"), "]"), (.base("0"), "}"),
        (.base("ß"), "\\"), (.base("+"), "~"), (.base("<"), "|"),
    ])

    private static let swiss = PCLayout(altGr: [
        (.base("1"), "¦"), (.base("2"), "@"), (.base("3"), "#"), (.base("4"), "°"), (.base("5"), "§"),
        (.base("6"), "¬"), (.base("7"), "|"), (.base("8"), "¢"), (.base("e"), "€"),
        (leftBracketKey, "["), (rightBracketKey, "]"), (quoteKey, "{"), (backslashKey, "}"), (.base("<"), "\\"),
    ])

    private static let spanish = PCLayout(altGr: [
        (.base("º"), "\\"), (.base("1"), "|"), (.base("2"), "@"), (.base("3"), "#"), (.base("6"), "¬"),
        (.base("e"), "€"), (leftBracketKey, "["), (.base("+"), "]"), (quoteKey, "{"), (.base("ç"), "}"),
    ])

    private static let italian = PCLayout(
        altGr: [(.base("e"), "€"), (.base("è"), "["), (.base("+"), "]"), (.base("ò"), "@"), (.base("à"), "#")],
        shiftAltGr: [(.base("è"), "{"), (.base("+"), "}")]
    )

    private static let nordicAltGr: [(Key, Character)] = [
        (.base("2"), "@"), (.base("3"), "£"), (.base("4"), "$"), (.base("5"), "€"),
        (.base("7"), "{"), (.base("8"), "["), (.base("9"), "]"), (.base("0"), "}"),
        (.base("e"), "€"), (.base("m"), "µ"),
    ]

    private static let swedish = PCLayout(
        changes: [
            Change(key: .base("§"), shifted: true, character: "½"),
            Change(key: .base("4"), shifted: true, character: "¤"),
        ],
        altGr: nordicAltGr + [(.base("+"), "\\"), (.base("<"), "|")]
    )

    private static let danish = PCLayout(
        changes: [
            Change(key: .base("$"), shifted: false, character: "½"),
            Change(key: .base("4"), shifted: true, character: "¤"),
        ],
        altGr: nordicAltGr + [(.base("<"), "\\"), (equalKey, "|")]
    )

    private static let norwegian = PCLayout(
        changes: [
            Change(key: .base("'"), shifted: false, character: "|"),
            Change(key: equalKey, shifted: false, character: "\\"),
            Change(key: .base("@"), shifted: false, character: "'"),
            Change(key: .base("4"), shifted: true, character: "¤"),
        ],
        altGr: nordicAltGr
    )

    private static let french = PCLayout(
        baseLayoutID: prefix + "French-PC",
        changes: [
            Change(key: .base("²"), shifted: true, character: nil),
            Change(key: .base("*"), shifted: true, character: "µ"),
        ],
        altGr: [
            (.base("\""), "#"), (.base("'"), "{"), (.base("("), "["), (.base("-"), "|"), (.base("_"), "\\"),
            (.base("ç"), "^"), (.base("à"), "@"), (.base(")"), "]"), (.base("="), "}"),
            (.base("e"), "€"), (.base("$"), "¤"),
        ]
    )

    private static let british = PCLayout(
        baseLayoutID: prefix + "British-PC",
        altGr: [
            (.base("`"), "¦"), (.base("4"), "€"),
            (.base("a"), "á"), (.base("e"), "é"), (.base("i"), "í"), (.base("o"), "ó"), (.base("u"), "ú"),
        ],
        shiftAltGr: [(.base("a"), "Á"), (.base("e"), "É"), (.base("i"), "Í"), (.base("o"), "Ó"), (.base("u"), "Ú")]
    )

    /// Keyed by macOS layout ID without `com.apple.keylayout.`.
    private static let layouts: [String: PCLayout] = [
        "German": german, "Austrian": german, "German-DIN-2137": german,
        "SwissGerman": swiss, "SwissFrench": swiss,
        "Spanish-ISO": spanish,
        "Italian-Pro": italian,
        "Swedish-Pro": swedish, "Finnish": swedish,
        "Danish": danish,
        "Norwegian": norwegian,
        "French": french, "French-numerical": french, "French-PC": french,
        "British": british, "British-PC": british,
    ]
}
