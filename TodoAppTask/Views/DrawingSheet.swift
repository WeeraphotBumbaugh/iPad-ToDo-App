//
//  DrawingSheet.swift
//  TodoAppTask
//

import SwiftUI
import PencilKit
import UIKit

struct DrawingSheet: View {
    let initialData: Data?
    let onSave: (Data?) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutDirection) private var layoutDirection

    @StateObject private var tools = ToolState()
    @State private var canvas = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var zoomScale: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                controlBar
                ZoomableCanvasView(canvasView: $canvas,
                                   toolPicker: $toolPicker,
                                   tools: tools,
                                   zoomScale: $zoomScale)
                    .background(Color(UIColor.systemBackground))
                    .ignoresSafeArea(.container, edges: .bottom)
            }
            .navigationTitle(String(localized: "Drawing Pad"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if layoutDirection == .leftToRight {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "Cancel")) {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(String(localized: "Save")) {
                            onSave(canvas.drawing.dataRepresentation())
                            dismiss()
                        }
                        .keyboardShortcut(.return, modifiers: [.command])
                    }
                } else {
                    // For RTL, reverse the button order to match regional conventions
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "Save")) {
                            onSave(canvas.drawing.dataRepresentation())
                            dismiss()
                        }
                        .keyboardShortcut(.return, modifiers: [.command])
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(String(localized: "Cancel")) {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                setupToolPicker()
                if let data = initialData, let dr = try? PKDrawing(data: data) {
                    canvas.drawing = dr
                }
            }
            .onChange(of: tools.requestUndo) { _, _ in canvas.undoManager?.undo() }
            .onChange(of: tools.requestRedo) { _, _ in canvas.undoManager?.redo() }
            .onChange(of: tools.requestClear) { _, _ in canvas.drawing = PKDrawing() }
        }
    }

    private var controlBar: some View {
        HStack(spacing: 12) {
            Menu {
                Picker("Tool", selection: $tools.currentTool) {
                    Label("Pen", systemImage: "pencil.tip").tag(ToolState.Kind.pen)
                    Label("Marker", systemImage: "highlighter").tag(ToolState.Kind.marker)
                    Label("Pencil", systemImage: "pencil").tag(ToolState.Kind.pencil)
                    Label("Eraser", systemImage: "eraser").tag(ToolState.Kind.eraser)
                }
            } label: {
                Image(systemName: iconForTool(tools.currentTool))
            }

            ColorPicker("", selection: $tools.color)
                .labelsHidden()
                .frame(width: 44, height: 32)

            HStack {
                Image(systemName: "minus.circle").onTapGesture { tools.bumpWidth(-2) }
                Slider(value: $tools.lineWidth, in: 1...50, step: 1).frame(maxWidth: 240)
                Image(systemName: "plus.circle").onTapGesture { tools.bumpWidth(+2) }
            }
            .frame(maxWidth: 360)

            Spacer()

            Button { canvas.undoManager?.undo() } label: { Image(systemName: "arrow.uturn.backward") }
                .keyboardShortcut("z", modifiers: .command)
            Button { canvas.undoManager?.redo() } label: { Image(systemName: "arrow.uturn.forward") }
                .keyboardShortcut("z", modifiers: [.command, .shift])
            Button { canvas.drawing = PKDrawing() } label: { Image(systemName: "trash") }
                .keyboardShortcut("k", modifiers: .command)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private func iconForTool(_ t: ToolState.Kind) -> String {
        switch t {
        case .pen: return "pencil.tip"
        case .marker: return "highlighter"
        case .pencil: return "pencil"
        case .eraser: return "eraser"
        }
    }

    private func setupToolPicker() {
        canvas.drawingPolicy = .anyInput
        toolPicker.setVisible(true, forFirstResponder: canvas)
        toolPicker.addObserver(canvas)
        canvas.becomeFirstResponder()
        canvas.tool = tools.makePKTool()
    }
}
