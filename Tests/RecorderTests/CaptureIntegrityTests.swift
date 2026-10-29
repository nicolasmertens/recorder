import Testing
import Foundation
@testable import Recorder

struct CaptureIntegrityTests {
    @Test func normalSilenceDoesNotRestartHealthyCapture() {
        #expect(CaptureIntegrity.shouldRestart(secondsSinceAudio: 600, secondsSinceCallback: 0.01) == false)
    }

    @Test func missingCallbacksTriggerRecovery() {
        #expect(CaptureIntegrity.shouldRestart(secondsSinceAudio: 10, secondsSinceCallback: 5))
    }

    @Test func halfLengthTrackCannotBeReportedAsComplete() {
        #expect(CaptureIntegrity.durationWarning(desktop: 2288.57, microphone: 4613.12) != nil)
    }

    @Test func missingTrackProducesWarning() {
        #expect(CaptureIntegrity.durationWarning(desktop: 0, microphone: 60) != nil)
        #expect(CaptureIntegrity.durationWarning(desktop: 60, microphone: 0) != nil)
    }

    @Test func smallStartSkewIsTolerated() {
        #expect(CaptureIntegrity.durationWarning(desktop: 60, microphone: 59.9) == nil)
    }

    @Test func invalidDurationsProduceWarning() {
        #expect(CaptureIntegrity.durationWarning(desktop: .nan, microphone: 60) != nil)
        #expect(CaptureIntegrity.durationWarning(desktop: 60, microphone: .infinity) != nil)
    }

    @Test func savedReportRetainsMismatchAndDoesNotClaimVerifiedContent() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let report = CaptureIntegrityReport(
            desktop: CaptureResult(sampleRate: 48000, frameCount: 48000 * 30),
            microphone: CaptureResult(sampleRate: 24000, frameCount: 24000 * 60)
        )
        try report.write(to: folder)
        let saved = try JSONDecoder().decode(CaptureIntegrityReport.self,
            from: Data(contentsOf: folder.appendingPathComponent("capture-integrity.json")))
        #expect(saved.desktopSeconds == 30)
        #expect(saved.microphoneSeconds == 60)
        #expect(saved.warning != nil)
        #expect(saved.contentVerified == false)
    }
}
