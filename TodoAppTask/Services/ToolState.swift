//
//  ToolState.swift
//  TodoAppTask
//

import SwiftUI
import PencilKit

final class ToolState: ObservableObject {
    enum Kind { case pen, marker, pencil, eraser }

    @Published var currentTool: Kind = .pen
    @Published var color: Color = .blue
    @Published var lineWidth: CGFloat = 6

    // fire-and-forget toggles for actions from keyboard
    @Published var requestUndo = false
    @Published var requestRedo = false
    @Published var requestClear = false

    func bumpWidth(_ delta: CGFloat) {
        lineWidth = max(1, min(50, lineWidth + delta))
    }

    func makePKTool() -> PKTool {
        switch currentTool {
        case .eraser:
            return PKEraserTool(.bitmap)
        case .pen:
            return PKInkingTool(.pen, color: UIColor(color), width: lineWidth)
        case .marker:
            return PKInkingTool(.marker, color: UIColor(color), width: lineWidth)
        case .pencil:
            return PKInkingTool(.pencil, color: UIColor(color), width: lineWidth)
        }
    }
}
