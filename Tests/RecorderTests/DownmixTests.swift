import Testing
@testable import Recorder

struct DownmixTests {
    /// Interleaved stereo must come out as one mono frame per input frame, at the same rate.
    /// The old planar read kept half the frames with L and R alternating (half speed on replay).
    @Test func interleavedStereoKeepsEveryFrame() {
        let frames = 6
        var src: [Float] = []
        for i in 0..<frames { src += [Float(i), Float(i) + 0.5] }   // L = i, R = i + 0.5
        var dst = [Float](repeating: -1, count: frames)
        src.withUnsafeBufferPointer { s in
            dst.withUnsafeMutableBufferPointer { d in
                SystemAudioTap.downmixInterleaved(s.baseAddress!, frames: frames, channels: 2, into: d.baseAddress!)
            }
        }
        #expect(dst == (0..<frames).map { Float($0) + 0.25 })
    }
}
