import SwiftUI

struct DrawingStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var width: CGFloat
    var opacity: Double
    var isEraser: Bool
}

enum DrawingTool: CaseIterable {
    case select, pan, brush, eraser, layers, image, palette

    var symbol: String {
        switch self {
        case .select: return "scissors"
        case .pan: return "hand.point.up.left"
        case .brush: return "paintbrush.pointed"
        case .eraser: return "eraser"
        case .layers: return "square.on.square"
        case .image: return "photo.badge.plus"
        case .palette: return "paintpalette"
        }
    }
}

struct DrawingView: View {

    var onClose: () -> Void = {}
    var onLayers: () -> Void = {}
    var onAddImage: () -> Void = {}

    @State private var strokes: [DrawingStroke] = []
    @State private var redoStack: [DrawingStroke] = []
    @State private var current: DrawingStroke? = nil

    @State private var tool: DrawingTool = .brush
    @State private var color: Color = .black
    @State private var sizeValue: Double = 0.2
    @State private var opacityValue: Double = 1.0

    @State private var showSidePanel = true
    @State private var showToolbar = true
    @State private var showColors = false

    private let paperColor = Color(red: 0.99, green: 0.98, blue: 0.97)

    private let paletteColors: [Color] = [
        .black, .gray, .red, .orange, .yellow, .green, .blue, .purple, .brown
    ]

    private var brushWidth: CGFloat {
        CGFloat(1 + sizeValue * 39)
    }

    private var brushOpacity: Double {
        0.05 + opacityValue * 0.95
    }

    var body: some View {
        ZStack {
            canvas
            closeButton
            sidePanel
            bottomBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image(.back)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }

    private var canvas: some View {
        Canvas { context, _ in
            context.drawLayer { layer in
                for s in strokes {
                    draw(s, in: &layer)
                }
                if let c = current {
                    draw(c, in: &layer)
                }
            }
        }
        .background(paperColor)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .gesture(drawGesture)
        .padding(.top, 60)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private var drawGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard tool == .brush || tool == .eraser else { return }
                if current == nil {
                    current = DrawingStroke(
                        points: [value.location],
                        color: color,
                        width: brushWidth,
                        opacity: tool == .eraser ? 1 : brushOpacity,
                        isEraser: tool == .eraser
                    )
                    showColors = false
                } else {
                    current?.points.append(value.location)
                }
            }
            .onEnded { _ in
                if let c = current {
                    strokes.append(c)
                    redoStack.removeAll()
                }
                current = nil
            }
    }

    private func draw(_ s: DrawingStroke, in ctx: inout GraphicsContext) {
        ctx.blendMode = s.isEraser ? .clear : .normal

        if s.points.count == 1 {
            let p = s.points[0]
            let r = s.width / 2
            let rect = CGRect(x: p.x - r, y: p.y - r, width: s.width, height: s.width)
            ctx.fill(Path(ellipseIn: rect), with: .color(s.color.opacity(s.opacity)))
        } else {
            ctx.stroke(
                smoothPath(s.points),
                with: .color(s.color.opacity(s.opacity)),
                style: StrokeStyle(lineWidth: s.width, lineCap: .round, lineJoin: .round)
            )
        }

        ctx.blendMode = .normal
    }

    private func smoothPath(_ pts: [CGPoint]) -> Path {
        var path = Path()
        guard let first = pts.first else { return path }
        path.move(to: first)

        if pts.count < 3 {
            for p in pts.dropFirst() {
                path.addLine(to: p)
            }
            return path
        }

        for i in 1..<(pts.count - 1) {
            let mid = CGPoint(
                x: (pts[i].x + pts[i + 1].x) / 2,
                y: (pts[i].y + pts[i + 1].y) / 2
            )
            path.addQuadCurve(to: mid, control: pts[i])
        }
        path.addLine(to: pts[pts.count - 1])
        return path
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
                .padding(14)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var sidePanel: some View {
        HStack(spacing: 8) {
            VStack(spacing: 8) {
                VerticalPillSlider(value: $sizeValue)
                    .frame(height: 105)

                RoundedRectangle(cornerRadius: 3)
                    .fill(color.opacity(brushOpacity))
                    .frame(width: 16, height: 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1)
                    )

                VerticalPillSlider(value: $opacityValue)
                    .frame(height: 105)

                Button(action: undo) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .opacity(strokes.isEmpty ? 0.4 : 1)
                        .frame(width: 30, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(strokes.isEmpty)

                Button(action: redo) {
                    Image(systemName: "arrow.uturn.forward")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .opacity(redoStack.isEmpty ? 0.4 : 1)
                        .frame(width: 30, height: 24)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(redoStack.isEmpty)
            }
            .padding(.vertical, 10)
            .frame(width: 42)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.gray.opacity(0.35))
            )

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showSidePanel.toggle()
                }
            } label: {
                Image(systemName: showSidePanel ? "chevron.left" : "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 26, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.gray.opacity(0.35))
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .offset(x: showSidePanel ? 0 : -50)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.leading, 6)
    }

    private var bottomBar: some View {
        VStack(spacing: 8) {
            if showColors && showToolbar {
                colorRow
            }

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showToolbar.toggle()
                    if !showToolbar { showColors = false }
                }
            } label: {
                Image(systemName: showToolbar ? "chevron.down" : "chevron.up")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 18)
                    .background(Capsule().fill(Color.gray.opacity(0.25)))
            }
            .buttonStyle(PlainButtonStyle())

            if showToolbar {
                toolbar
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 12)
    }

    private var toolbar: some View {
        HStack(spacing: 22) {
            ForEach(DrawingTool.allCases, id: \.self) { t in
                Button {
                    choose(t)
                } label: {
                    Image(systemName: t.symbol)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .opacity(isHighlighted(t) ? 1 : 0.6)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle().fill(Color.black.opacity(isHighlighted(t) ? 0.1 : 0))
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.9))
                .overlay(Capsule().strokeBorder(Color.gray.opacity(0.3), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
        )
    }

    private var colorRow: some View {
        HStack(spacing: 12) {
            ForEach(paletteColors, id: \.self) { c in
                Button {
                    color = c
                    if tool != .brush { tool = .brush }
                } label: {
                    Circle()
                        .fill(c)
                        .frame(width: 26, height: 26)
                        .overlay(
                            Circle().strokeBorder(
                                Color.white,
                                lineWidth: color == c ? 3 : 0
                            )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
        )
        .transition(.opacity)
    }

    private func isHighlighted(_ t: DrawingTool) -> Bool {
        switch t {
        case .palette: return showColors
        case .layers, .image: return false
        default: return tool == t
        }
    }

    private func choose(_ t: DrawingTool) {
        switch t {
        case .layers:
            onLayers()
        case .image:
            onAddImage()
        case .palette:
            withAnimation(.easeInOut(duration: 0.2)) {
                showColors.toggle()
            }
        default:
            tool = t
            showColors = false
        }
    }

    private func undo() {
        guard let last = strokes.popLast() else { return }
        redoStack.append(last)
    }

    private func redo() {
        guard let last = redoStack.popLast() else { return }
        strokes.append(last)
    }
}

struct VerticalPillSlider: View {

    @Binding var value: Double

    var body: some View {
        GeometryReader { geo in
            let thumbHeight: CGFloat = 18
            let travel = max(geo.size.height - thumbHeight, 1)

            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.gray.opacity(0.55))

                Capsule()
                    .fill(Color.white)
                    .frame(width: max(geo.size.width - 4, 10), height: thumbHeight)
                    .offset(y: travel * CGFloat(1 - value))
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        let p = 1 - (g.location.y - thumbHeight / 2) / travel
                        value = Double(min(max(p, 0), 1))
                    }
            )
        }
    }
}

#Preview {
    DrawingView()
}
