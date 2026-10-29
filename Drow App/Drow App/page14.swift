import SwiftUI
import PencilKit

struct Page14: View {
    // يرجع الاسم والتوقيع لما يضغط السهم
  var onContinue: (String, UIImage, Data) -> Void = { _, _, _ in }   // name, signature picture, signature strokes

    // When editing a saved drawing, its old name and signature are shown first
    var initialName = ""
    var initialStrokes = Data()
    @State private var didLoadInitial = false

    @State private var sketchName: String = ""
    @State private var canvas = PKCanvasView()
    @State private var useEraser = false
    @State private var allowFinger = true

    // The fields use the same gold as the arrow button, but softer
    private let fieldFill = Color.gold.opacity(0.25)
    private let fieldBorder = Color.gold.opacity(0.55)

    // MARK: - Body
    var body: some View {
        card
            .onAppear(perform: loadInitial)
    }

    /// Fills in the saved name and signature once, when editing.
    private func loadInitial() {
        guard !didLoadInitial else { return }
        didLoadInitial = true
        sketchName = initialName
        if let saved = try? PKDrawing(data: initialStrokes) {
            canvas.drawing = saved
        }
    }

    // MARK: - الكرت
    private var card: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 14) {
                // Name Sketch
                Text("Name Sketch")
                    .font(.system(size: 20))
                    .foregroundColor(.deepBrown)

                TextField("", text: $sketchName)
                    .font(.system(size: 20))
                    .foregroundColor(.deepBrown)
                    .padding(.horizontal, 18)
                    .frame(width: 287, height: 52)
                    .background(Capsule().fill(fieldFill))
                    .overlay(Capsule().stroke(fieldBorder, lineWidth: 1.5))

                // Signature
                Text("Signature")
                    .font(.system(size: 20))
                    .foregroundColor(.deepBrown)
                    .padding(.top, 6)

                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(fieldFill)
                        .overlay(RoundedRectangle(cornerRadius: 26).stroke(fieldBorder, lineWidth: 1.5))

                    SignatureCanvas(canvas: canvas, useEraser: useEraser, allowFinger: allowFinger)
                        .clipShape(RoundedRectangle(cornerRadius: 26))

                    // أدوات: يد / فرشاة / ممحاة
                    HStack(spacing: 10) {
                        toolButton("hand.point.up.left", active: allowFinger) {
                            allowFinger.toggle()
                        }
                        toolButton("paintbrush.pointed", active: !useEraser) {
                            useEraser = false
                        }
                        toolButton("eraser", active: useEraser) {
                            useEraser = true
                        }
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 14)
                }
                .frame(width: 287, height: 100)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 36)

            // سهم المتابعة
            Button {
                let image = canvas.drawing.image(
                    from: canvas.bounds,
                    scale: canvas.traitCollection.displayScale
                )
                onContinue(sketchName, image, canvas.drawing.dataRepresentation())
            } label: {
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
            .tint(Color.gold)
            .padding([.bottom, .trailing], 22)
            // Fills the card so the arrow sits in the bottom-right corner
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .frame(width: 440, height: 366)   // Taller than before, so the arrow sits below the signature box
        // The whole card is Liquid Glass, like the other dialogs in the app
        .glassEffect(.regular, in: .rect(cornerRadius: 34))
    }

    private func toolButton(_ icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.deepBrown.opacity(active ? 1 : 0.4))
        }
    }
}

// MARK: - لوحة التوقيع (PencilKit)
struct SignatureCanvas: UIViewRepresentable {
    let canvas: PKCanvasView
    var useEraser: Bool
    var allowFinger: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.overrideUserInterfaceStyle = .light
        canvas.drawingPolicy = allowFinger ? .anyInput : .pencilOnly
        canvas.tool = PKInkingTool(.pen, color: .black, width: 3)
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawingPolicy = allowFinger ? .anyInput : .pencilOnly
        uiView.tool = useEraser
            ? PKEraserTool(.bitmap)
            : PKInkingTool(.pen, color: .black, width: 3)
    }
}

#Preview {
    ZStack {
        Image("rere")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .blur(radius: 14)

        Page14()
    }
}
