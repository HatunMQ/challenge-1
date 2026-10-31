import SwiftUI
import PencilKit

/// Wraps PencilKit's canvas so it can be used in SwiftUI.
struct CanvasView: UIViewRepresentable {
    let canvas: PKCanvasView
    var tool: DrawTool
    var ink: InkType
    var color: Color
    var width: Double
    var opacity: Double

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.maximumZoomScale = 4
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        // The hand tool lets fingers move and zoom instead of drawing.
        canvas.drawingPolicy = tool == .hand ? .pencilOnly : .anyInput

        switch tool {
        case .brush:
            let uiColor = UIColor(color).withAlphaComponent(opacity)
            canvas.tool = PKInkingTool(pkInk, color: uiColor, width: width)
        case .eraser:
            canvas.tool = PKEraserTool(.bitmap)
        case .hand:
            break
        }
    }

    private var pkInk: PKInkingTool.InkType {
        switch ink {
        case .pen: .pen
        case .pencil: .pencil
        case .marker: .marker
        case .charcoal: .crayon
        case .watercolor: .watercolor
        case .calligraphy: .fountainPen
        case .fineLiner: .monoline
        }
    }
}

/// Apple's full color picker, shown when the user taps "+".
struct SystemColorPicker: UIViewControllerRepresentable {
    @Binding var color: Color

    func makeUIViewController(context: Context) -> UIColorPickerViewController {
        let picker = UIColorPickerViewController()
        picker.selectedColor = UIColor(color)
        picker.supportsAlpha = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ picker: UIColorPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(color: $color) }

    final class Coordinator: NSObject, UIColorPickerViewControllerDelegate {
        @Binding var color: Color

        init(color: Binding<Color>) { _color = color }

        func colorPickerViewController(_ picker: UIColorPickerViewController,
                                       didSelect color: UIColor, continuously: Bool) {
            self.color = Color(color)
        }
    }
}
