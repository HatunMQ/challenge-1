import SwiftUI
import PencilKit

struct Page14: View {
    // يرجع الاسم والتوقيع لما يضغط السهم
  var onContinue: (String, UIImage) -> Void = { _, _ in }

    @State private var sketchName: String = ""
    @State private var canvas = PKCanvasView()
    @State private var useEraser = false
    @State private var allowFinger = true
    @State private var showDone = false

    private let cardColor = Color(red: 0.95, green: 0.95, blue: 0.95)
    private let fieldColor = Color(red: 0.90, green: 0.90, blue: 0.90)

    // MARK: - Body
    var body: some View {
        card
            .fullScreenCover(isPresented: $showDone) {
                Page15(sketchName: sketchName)
            }
    }

    // MARK: - الكرت
    private var card: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 34)
                .fill(cardColor)
                .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 12)

            VStack(alignment: .leading, spacing: 14) {
                // Name Sketch
                Text("Name Sketch")
                    .font(.system(size: 20))
                    .foregroundColor(.black)

                TextField("", text: $sketchName)
                    .font(.system(size: 20))
                    .padding(.horizontal, 18)
                    .frame(width: 287, height: 52)
                    .background(
                        Capsule()
                            .fill(fieldColor)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.7), lineWidth: 1))

                // Signature
                Text("Signature")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .padding(.top, 6)

                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(fieldColor)
                        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

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
                onContinue(sketchName, image)
                showDone = true
            } label: {
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.gray.opacity(0.35)))
            }
            .padding(.top, 20)
            .padding(.trailing, 22)
        }
        .frame(width: 440, height: 322)
    }

    private func toolButton(_ icon: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.black.opacity(active ? 1 : 0.4))
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
