import Foundation

/// `Recorder --tap-selftest <out.caf> [seconds]`: capture system audio for a few seconds through
/// the real SystemAudioTap path, print what was written, and exit. Lets an agent verify capture
/// (e.g. play a known tone and check its pitch) without touching the menu-bar UI.
enum TapSelfTest {
    static func runIfRequested() {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--tap-selftest"), i + 1 < args.count else { return }
        let url = URL(fileURLWithPath: args[i + 1])
        let seconds = i + 2 < args.count ? (Double(args[i + 2]) ?? 5) : 5
        let tap = SystemAudioTap()
        do {
            try tap.start(writingTo: url)
        } catch {
            print("selftest: start failed: \(error)")
            exit(2)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            let result = tap.stop()
            print("selftest: sampleRate=\(result.sampleRate) frames=\(result.frameCount) seconds=\(seconds)")
            exit(result.frameCount > 0 ? 0 : 1)
        }
    }
}
