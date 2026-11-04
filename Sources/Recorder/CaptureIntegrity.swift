import Foundation

/// Pure capture-health decisions, kept independent of hardware for regression tests.
enum CaptureIntegrity {
    static func shouldRestart(secondsSinceAudio: Double, secondsSinceCallback: Double) -> Bool {
        // A quiet participant is not a broken capture. Only absent callbacks
        // justify rebuilding; zero-filled callbacks need a separate warning.
        secondsSinceCallback >= 3
    }

    static func durationWarning(desktop: Double, microphone: Double) -> String? {
        guard desktop.isFinite, microphone.isFinite, desktop > 0, microphone > 0 else {
            return "Audio incomplete: one track is empty or has invalid timing. Raw files kept."
        }
        guard abs(desktop - microphone) > 2 else { return nil }
        return String(format: "Audio timing mismatch: system %.1fs, mic %.1fs. Check raw files before relying on this mix.", desktop, microphone)
    }
}

/// Live health of a recording in progress, fed from the level meters and written-frame counts.
/// Catches the failures that cost us the Oct 29 and Nov 4 meetings while they can still be fixed:
/// the computer track falling behind the mic, and no computer audio while Nick is talking.
struct LiveCaptureCheck {
    static let silenceDB: Float = -60
    static let speechDB: Float = -40
    static let silentFor: TimeInterval = 120
    static let maxDrift: Double = 5
    static let warmup: Double = 15

    private(set) var desktopSilentSince: Date?
    private(set) var lastMicSpeech: Date?

    init(start: Date) { desktopSilentSince = start }

    mutating func noteDesktop(db: Float, at now: Date) {
        if db < Self.silenceDB {
            if desktopSilentSince == nil { desktopSilentSince = now }
        } else {
            desktopSilentSince = nil
        }
    }

    mutating func noteMic(db: Float, at now: Date) {
        if db > Self.speechDB { lastMicSpeech = now }
    }

    /// `desktopSeconds`/`micSeconds`: audio written to disk so far per track.
    func warning(at now: Date, desktopSeconds: Double, micSeconds: Double) -> String? {
        if micSeconds > Self.warmup, desktopSeconds.isFinite, micSeconds - desktopSeconds > Self.maxDrift {
            return String(format: "Computer audio is %.0fs behind your mic: the other side is not being fully recorded.",
                          micSeconds - desktopSeconds)
        }
        if let since = desktopSilentSince, now.timeIntervalSince(since) >= Self.silentFor,
           let talk = lastMicSpeech, talk > since {
            let minutes = Int(now.timeIntervalSince(since) / 60)
            return "No computer audio for \(minutes) min while you talk. If this is a call, the other side is not being recorded."
        }
        return nil
    }
}

struct CaptureIntegrityReport: Codable {
    var desktopSeconds: Double
    var microphoneSeconds: Double
    var warning: String?
    // Matching durations cannot establish content completeness.
    var contentVerified = false

    init(desktop: CaptureResult, microphone: CaptureResult) {
        desktopSeconds = desktop.sampleRate > 0 ? Double(desktop.frameCount) / desktop.sampleRate : 0
        microphoneSeconds = microphone.sampleRate > 0 ? Double(microphone.frameCount) / microphone.sampleRate : 0
        warning = CaptureIntegrity.durationWarning(desktop: desktopSeconds, microphone: microphoneSeconds)
    }

    func write(to folder: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(self).write(to: folder.appendingPathComponent("capture-integrity.json"), options: .atomic)
    }
}
