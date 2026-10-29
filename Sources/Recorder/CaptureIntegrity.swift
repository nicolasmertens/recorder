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
