#if os(macOS)
    import AppKit
    import SwiftUI

    struct CameraInputView: NSViewRepresentable {
        let onOrbit: (CGSize) -> Void
        let onPan: (CGSize) -> Void
        let onZoom: (CGFloat) -> Void

        func makeNSView(context _: Context) -> CameraInputNSView {
            CameraInputNSView(onOrbit: onOrbit, onPan: onPan, onZoom: onZoom)
        }

        func updateNSView(_ inputView: CameraInputNSView, context _: Context) {
            inputView.onOrbit = onOrbit
            inputView.onPan = onPan
            inputView.onZoom = onZoom
        }
    }

    final class CameraInputNSView: NSView {
        var onOrbit: (CGSize) -> Void
        var onPan: (CGSize) -> Void
        var onZoom: (CGFloat) -> Void
        private var lastDragLocation: NSPoint?

        init(
            onOrbit: @escaping (CGSize) -> Void,
            onPan: @escaping (CGSize) -> Void,
            onZoom: @escaping (CGFloat) -> Void
        ) {
            self.onOrbit = onOrbit
            self.onPan = onPan
            self.onZoom = onZoom
            super.init(frame: .zero)
        }

        required init?(coder _: NSCoder) {
            nil
        }

        override func mouseDown(with event: NSEvent) {
            lastDragLocation = event.locationInWindow
        }

        override func mouseDragged(with event: NSEvent) {
            guard let lastDragLocation else { return }
            let location = event.locationInWindow
            let translation = CGSize(width: location.x - lastDragLocation.x, height: location.y - lastDragLocation.y)
            self.lastDragLocation = location

            if event.modifierFlags.contains(.shift) {
                onPan(translation)
            } else {
                onOrbit(translation)
            }
        }

        override func mouseUp(with _: NSEvent) {
            lastDragLocation = nil
        }

        override func scrollWheel(with event: NSEvent) {
            onZoom(event.scrollingDeltaY)
        }
    }
#endif
