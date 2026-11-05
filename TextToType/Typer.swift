import AppKit
import Carbon.HIToolbox
import CoreGraphics

/// Cancellation token shared between the UI and the typing thread.
final class TypingJob {
    private let lock = NSLock()
    private var cancelled = false

    var isCancelled: Bool {
        lock.lock(); defer { lock.unlock() }
        return cancelled
    }

    func cancel() {
        lock.lock(); cancelled = true; lock.unlock()
    }
}

/// Types text by posting real keyboard events, as if typed on the keyboard.
enum Typer {
    /// Must be called on the main thread. `completion` is called on the main thread.
    static func start(
        text: String,
        keyDelay: TimeInterval,
        startDelay: TimeInterval,
        target: TargetSystem,
        job: TypingJob,
        completion: @escaping () -> Void
    ) {
        // Resolve the keyboard layout on the main thread before going to the background.
        let map = KeyboardLayout.characterMap(for: target)

        let thread = Thread {
            defer { DispatchQueue.main.async(execute: completion) }

            // Don't start while the user still holds the hotkey's modifiers,
            // otherwise e.g. ⌘ would turn typed letters into shortcuts.
            waitForModifierRelease(job: job, timeout: 3)
            Thread.sleep(forTimeInterval: startDelay)

            let source = CGEventSource(stateID: .hidSystemState)
            for character in text {
                if job.isCancelled { return }
                type(character, map: map, source: source)
                if keyDelay > 0 { Thread.sleep(forTimeInterval: keyDelay) }
            }
        }
        thread.qualityOfService = .userInteractive
        thread.start()
    }

    // MARK: Private

    private static func waitForModifierRelease(job: TypingJob, timeout: TimeInterval) {
        let mask: CGEventFlags = [.maskCommand, .maskControl, .maskAlternate, .maskShift]
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline, !job.isCancelled {
            if CGEventSource.flagsState(.combinedSessionState).intersection(mask).isEmpty { return }
            Thread.sleep(forTimeInterval: 0.02)
        }
    }

    private static func type(_ character: Character, map: [Character: KeyStroke], source: CGEventSource?) {
        if character.isNewline {
            press(KeyStroke(keyCode: CGKeyCode(kVK_Return), modifiers: []), source: source)
        } else if character == "\t" {
            press(KeyStroke(keyCode: CGKeyCode(kVK_Tab), modifiers: []), source: source)
        } else if let stroke = map[character] {
            press(stroke, source: source)
        } else {
            // Not reachable via a key on this layout (emoji, accented chars behind dead keys, …).
            typeUnicode(String(character), source: source)
        }
    }

    /// Presses a key the way a human would: modifier(s) down, key down/up, modifier(s) up.
    private static func press(_ stroke: KeyStroke, source: CGEventSource?) {
        var current: CGEventFlags = []
        for modifier in stroke.modifiers {
            current.formUnion(modifier.flags)
            post(modifier.keyCode, down: true, flags: current, source: source)
        }

        post(stroke.keyCode, down: true, flags: current, source: source)
        usleep(2000)
        post(stroke.keyCode, down: false, flags: current, source: source)

        for (index, modifier) in stroke.modifiers.enumerated().reversed() {
            current = stroke.modifiers[..<index].reduce(into: []) { $0.formUnion($1.flags) }
            post(modifier.keyCode, down: false, flags: current, source: source)
        }
    }

    private static func post(_ keyCode: CGKeyCode, down: Bool, flags: CGEventFlags, source: CGEventSource?) {
        guard let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: down) else { return }
        event.flags = flags
        event.post(tap: .cghidEventTap)
    }

    private static func typeUnicode(_ string: String, source: CGEventSource?) {
        let utf16 = Array(string.utf16)
        // CGEvent carries at most ~20 UTF-16 units per event.
        for start in stride(from: 0, to: utf16.count, by: 20) {
            let chunk = Array(utf16[start..<min(start + 20, utf16.count)])
            for down in [true, false] {
                guard let event = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: down) else { continue }
                event.flags = []
                chunk.withUnsafeBufferPointer {
                    event.keyboardSetUnicodeString(stringLength: chunk.count, unicodeString: $0.baseAddress)
                }
                event.post(tap: .cghidEventTap)
            }
        }
    }
}
