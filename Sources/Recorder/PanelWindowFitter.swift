import AppKit
import SwiftUI

/// Keeps the menu-bar window exactly as tall as the panel content.
///
/// `MenuBarExtra(.window)` grows its window when content grows but never shrinks it,
/// so after a section disappears (a meeting rolls off, the transcription section
/// hides) the panel sat at the bottom of an oversized window with a blank band on
/// top. This view finds the hosting window and resizes it to the measured content
/// height, keeping the top edge pinned under the menu bar.
struct PanelWindowFitter: NSViewRepresentable {
    let contentHeight: CGFloat

    func makeNSView(context: Context) -> NSView { NSView() }

    func updateNSView(_ nsView: NSView, context: Context) {
        let height = contentHeight
        // The view joins its window after the first layout pass.
        DispatchQueue.main.async {
            guard let window = nsView.window, height > 0 else { return }
            let current = window.contentRect(forFrameRect: window.frame)
            guard abs(current.height - height) > 0.5 else { return }
            var content = current
            content.origin.y = current.maxY - height
            content.size.height = height
            window.setFrame(window.frameRect(forContentRect: content), display: true)
        }
    }
}
