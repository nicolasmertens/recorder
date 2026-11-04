import Testing
import Foundation
@testable import Recorder

struct LiveCaptureCheckTests {
    private let t0 = Date(timeIntervalSince1970: 0)
    private func at(_ s: TimeInterval) -> Date { t0.addingTimeInterval(s) }

    @Test func healthyCallHasNoWarning() {
        var check = LiveCaptureCheck(start: t0)
        for s in stride(from: 0.0, through: 300, by: 1) {
            check.noteDesktop(db: -25, at: at(s)); check.noteMic(db: -20, at: at(s))
        }
        #expect(check.warning(at: at(300), desktopSeconds: 299.6, micSeconds: 300) == nil)
    }

    /// Oct 29 Jeroen: computer track 2288 s against a 4613 s mic track.
    @Test func computerTrackFallingBehindWarns() {
        let check = LiveCaptureCheck(start: t0)
        #expect(check.warning(at: at(60), desktopSeconds: 50, micSeconds: 60) != nil)
    }

    @Test func noComputerAudioWhileTalkingWarns() {
        var check = LiveCaptureCheck(start: t0)
        for s in stride(from: 0.0, through: 130, by: 1) {
            check.noteDesktop(db: -90, at: at(s)); check.noteMic(db: -20, at: at(s))
        }
        #expect(check.warning(at: at(130), desktopSeconds: 130, micSeconds: 130) != nil)
    }

    @Test func quietOtherSideForAMinuteIsFine() {
        var check = LiveCaptureCheck(start: t0)
        check.noteDesktop(db: -20, at: at(0))
        for s in stride(from: 1.0, through: 60, by: 1) {
            check.noteDesktop(db: -90, at: at(s)); check.noteMic(db: -20, at: at(s))
        }
        #expect(check.warning(at: at(60), desktopSeconds: 60, micSeconds: 60) == nil)
    }

    @Test func bothSilentIsNotAWarning() {
        var check = LiveCaptureCheck(start: t0)
        for s in stride(from: 0.0, through: 300, by: 1) {
            check.noteDesktop(db: -90, at: at(s)); check.noteMic(db: -70, at: at(s))
        }
        #expect(check.warning(at: at(300), desktopSeconds: 300, micSeconds: 300) == nil)
    }
}
