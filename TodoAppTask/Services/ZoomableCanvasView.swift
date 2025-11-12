//
//  ZoomableCanvasView.swift
//  TodoAppTask
//

import SwiftUI
import PencilKit

struct ZoomableCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    @ObservedObject var tools: ToolState
    @Binding var zoomScale: CGFloat

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UIScrollView {
        let scroll = UIScrollView()
        scroll.delegate = context.coordinator
        scroll.minimumZoomScale = 0.5
        scroll.maximumZoomScale = 4.0
        scroll.bouncesZoom = true
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.delaysContentTouches = false
        scroll.canCancelContentTouches = true

        // Require two fingers to pan so one finger can draw. Trackpad works with pinch/scroll.
        scroll.panGestureRecognizer.minimumNumberOfTouches = 2

        // Container to zoom
        let container = context.coordinator.container
        container.frame = scroll.bounds
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scroll.addSubview(container)

        // Canvas fills container
        canvasView.frame = container.bounds
        canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = tools.makePKTool()
        canvasView.delegate = context.coordinator

        // Two-finger swipes for undo/redo (trackpad friendly)
        let swipeLeft = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.swipeLeft))
        swipeLeft.direction = .left
        swipeLeft.numberOfTouchesRequired = 2
        let swipeRight = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.swipeRight))
        swipeRight.direction = .right
        swipeRight.numberOfTouchesRequired = 2
        scroll.addGestureRecognizer(swipeLeft)
        scroll.addGestureRecognizer(swipeRight)

        // Apple Pencil double-tap to toggle eraser if available
        if UIPencilInteraction.prefersPencilOnlyDrawing {
            let pencil = UIPencilInteraction()
            pencil.delegate = context.coordinator
            scroll.addInteraction(pencil)
        }

        container.addSubview(canvasView)
        return scroll
    }

    func updateUIView(_ scroll: UIScrollView, context: Context) {
        canvasView.tool = tools.makePKTool()
    }

    class Coordinator: NSObject, UIScrollViewDelegate, PKCanvasViewDelegate, UIGestureRecognizerDelegate, UIPencilInteractionDelegate {
        let parent: ZoomableCanvasView
        // The view that actually gets scaled
        let container = UIView()

        init(_ parent: ZoomableCanvasView) { self.parent = parent }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? { container }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            parent.zoomScale = scrollView.zoomScale
            // keep the zoomed content centered
            let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
            parent.canvasView.superview?.center = CGPoint(
                x: scrollView.contentSize.width * 0.5 + offsetX,
                y: scrollView.contentSize.height * 0.5 + offsetY
            )
        }

        // Two-finger swipes for undo/redo
        @objc func swipeLeft() { parent.canvasView.undoManager?.undo() }
        @objc func swipeRight() { parent.canvasView.undoManager?.redo() }

        // Pencil double-tap toggles eraser/previous tool
        func pencilInteractionDidTap(_ interaction: UIPencilInteraction) {
            if case .eraser = parent.tools.currentTool {
                parent.tools.currentTool = .pen
            } else {
                parent.tools.currentTool = .eraser
            }
            parent.canvasView.tool = parent.tools.makePKTool()
        }
    }
}
