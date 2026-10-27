import SwiftUI
import PencilKit
import Combine

struct DrawingView: View {
    let mood: Mood?                 // nil when the user skipped the mood page
    var withScenario = true         // false for "Free draw": no drawing idea is shown
    var breakMinutes: Int? = 20     // Minutes of drawing before the break card shows; nil means no break reminder
    var onClose: (() -> Void)?      // Goes to the Home page. Linked later by the team; does nothing until then.

    // Break timer
    @State private var secondsLeft = 0
    @State private var showBreak = false   // Shows the pass card (and Deep Breath) on top of the drawing
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @ObservedObject private var player = SoundPlayer.shared

    // Drawing
    @State private var canvas = PKCanvasView()
    @State private var tool = DrawTool.brush
    @State private var ink = InkType.pen
    @State private var color = Color.softOrange
    @State private var width = 6.0
    @State private var opacity = 1.0
    @State private var redoStack: [PKStroke] = []

    // Pages
    private let maxPages = 2
    @State private var pages = [PKDrawing()]
    @State private var currentPage = 0

    // Panels
    @State private var showSliders = true
    @State private var showToolbar = true
    @State private var showBrushes = false
    @State private var showPages = false
    @State private var showScenario = false
    @State private var showColors = false
    @State private var showFullPicker = false
    @State private var showDeleteAlert = false
    @StateObject private var ideas = ScenarioGenerator()

    var body: some View {
        ZStack {
            AuraBackground()

            CanvasView(canvas: canvas, tool: tool, ink: ink, color: color, width: width, opacity: opacity)
                .background(Color.paper)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding([.horizontal, .bottom], 12)
                // Apple Pencil: double-tap switches between the brush and the eraser
                .onPencilDoubleTap { _ in
                    tool = tool == .eraser ? .brush : .eraser
                }

            topBar
            slidersPanel
            bottomBar
        }
        .navigationBarBackButtonHidden()
        .task {
            guard withScenario else { return }   // Free draw: skip the scenario
            try? await Task.sleep(for: .milliseconds(600))   // wait for the page to finish opening
            showScenario = true
            await ideas.showNext(for: mood)
        }
        .onDisappear { player.stop() }
        .onAppear { secondsLeft = (breakMinutes ?? 0) * 60 }
        .onReceive(ticker) { _ in countDown() }
        // Covers the page instead of leaving it, so the drawing is kept when the user comes back
        .fullScreenCover(isPresented: $showBreak) {
            BreakFlowView {
                showBreak = false
                secondsLeft = (breakMinutes ?? 0) * 60   // start the next drawing period
            }
        }
        .alert("Delete this page?", isPresented: $showDeleteAlert) {
            Button("No", role: .cancel) {}
            Button("Yes", role: .destructive) { deletePage() }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button {
                onClose?()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2.weight(.semibold))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Close")

            Spacer()

            if pages.count > 1 {
                Text("Page \(currentPage + 1) of \(pages.count)")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .foregroundStyle(Color.deepBrown)
        .padding(.horizontal, 24)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    /// Counts down once a second and shows the break reminder at zero.
    private func countDown() {
        guard breakMinutes != nil, secondsLeft > 0, !showBreak else { return }
        secondsLeft -= 1
        if secondsLeft == 0 { showBreak = true }
    }

    // MARK: - Left sliders (size, opacity, undo, redo)

    private var slidersPanel: some View {
        HStack(spacing: 6) {
            if showSliders {
                VStack(spacing: 14) {
                    VerticalSlider(value: $width, range: 1...30)
                        .accessibilityLabel("Brush size")
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(opacity))
                        .frame(width: 26, height: 22)
                    VerticalSlider(value: $opacity, range: 0.1...1)
                        .accessibilityLabel("Opacity")
                    Button(action: undo) { Image(systemName: "arrow.uturn.backward") }
                        .accessibilityLabel("Undo")
                    Button(action: redo) { Image(systemName: "arrow.uturn.forward") }
                        .accessibilityLabel("Redo")
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                .transition(.move(edge: .leading).combined(with: .opacity))
            }

            handle(showSliders ? "chevron.left" : "chevron.right") { showSliders.toggle() }
        }
        .foregroundStyle(Color.deepBrown)
        .padding(.leading, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Bottom toolbar

    private var bottomBar: some View {
        VStack(spacing: 10) {
            handle(showToolbar ? "chevron.down" : "chevron.up") { showToolbar.toggle() }

            if showToolbar {
                HStack(spacing: 22) {
                    barButton(player.isMuted ? "speaker.slash" : "music.note", label: "Music") {
                        player.toggleMute()
                    }
                    barButton("hand.point.up.left", isOn: tool == .hand, label: "Move") {
                        tool = .hand
                    }
                    barButton(ink.icon, isOn: tool == .brush, label: "Brush") {
                        if tool == .brush { showBrushes = true } else { tool = .brush }
                    }
                    .popover(isPresented: $showBrushes) { brushPicker }

                    barButton("eraser", isOn: tool == .eraser, label: "Eraser") {
                        tool = .eraser
                    }
                    barButton("square.on.square", label: "Pages") {
                        showPages = true
                    }
                    .popover(isPresented: $showPages) { pagesPicker }

                    if withScenario {
                        barButton("text.badge.star", label: "Drawing idea") {
                            showScenario = true
                        }
                        .popover(isPresented: $showScenario) { scenarioCard }
                    }

                    barButton("paintpalette", isOn: showColors, label: "Colors") {
                        showColors = true
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Circle().fill(color).frame(width: 12, height: 12)
                    }
                    .popover(isPresented: $showColors) { colorsPicker }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 26)
    }

    // MARK: - Popovers

    private var brushPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(78)), count: 4), spacing: 12) {
            ForEach(InkType.allCases) { item in
                Button {
                    ink = item
                    showBrushes = false
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: item.icon)
                            .font(.title2)
                            .frame(width: 52, height: 52)
                            .background(ink == item ? Color.starYellow : .appCream,
                                        in: RoundedRectangle(cornerRadius: 14))
                        Text(item.rawValue)
                            .font(.caption.weight(.semibold))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(Color.deepBrown)
        .padding(20)
    }

    private var pagesPicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ForEach(pages.indices, id: \.self) { index in
                    Button { openPage(index) } label: {
                        pageThumbnail(index)
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(index == currentPage ? Color.starYellow : .gold, lineWidth: 3))
                    }
                }
                if pages.count < maxPages {
                    Button(action: addPage) {
                        Image(systemName: "plus")
                            .font(.title)
                            .frame(width: 90, height: 120)
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gold, style: StrokeStyle(lineWidth: 2, dash: [6])))
                    }
                    .accessibilityLabel("New page")
                }
            }
            if pages.count > 1 {
                Button("Delete this page", systemImage: "trash", role: .destructive) {
                    showPages = false
                    showDeleteAlert = true
                }
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.deepBrown)
        .padding(20)
    }

    private var scenarioCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if ideas.isLoading || ideas.current == nil {
                ProgressView("Thinking of an idea…")
            } else if let idea = ideas.current {
                Label(idea.title, systemImage: "sun.max.fill")
                    .font(.headline)
                Text(idea.text)
            }

            HStack {
                Button("Another idea", systemImage: "arrow.triangle.2.circlepath") {
                    Task { await ideas.showNext(for: mood) }
                }
                .font(.subheadline.bold())
                .tint(.softOrange)
                .disabled(ideas.isLoading)

                Spacer()

                if ideas.usesAI {
                    Label("On-device AI", systemImage: "apple.intelligence")
                        .font(.caption)
                        .foregroundStyle(Color.softBrown)
                }
            }
        }
        .foregroundStyle(Color.deepBrown)
        .padding(20)
        .frame(width: 360)
    }

    /// Shows the suggested colors, or Apple's full picker after tapping "+".
    private var colorsPicker: some View {
        Group {
            if showFullPicker {
                VStack(alignment: .leading, spacing: 0) {
                    Button("Suggested colors", systemImage: "chevron.left") {
                        withAnimation { showFullPicker = false }
                    }
                    .font(.subheadline.bold())
                    .tint(.softOrange)
                    .padding([.horizontal, .top], 16)

                    SystemColorPicker(color: $color)
                        .frame(width: 380, height: 560)
                        .onChange(of: color) { tool = .brush }
                }
            } else {
                suggestedColorsView
            }
        }
        .onDisappear { showFullPicker = false }
    }

    /// 4 colors that suit the current idea, plus "+" for all colors.
    private var suggestedColorsView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Suggested colors")
                .font(.headline)

            HStack(spacing: 14) {
                ForEach(suggestedColors, id: \.self) { hex in
                    let swatch = Color(hex: hex)
                    Circle()
                        .fill(swatch)
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Color.deepBrown, lineWidth: color == swatch ? 3 : 0))
                        .onTapGesture {
                            color = swatch
                            tool = .brush
                        }
                }

                Button {
                    withAnimation { showFullPicker = true }
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.bold())
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Color.gold, style: StrokeStyle(lineWidth: 2, dash: [4])))
                }
                .accessibilityLabel("More colors")
            }
        }
        .foregroundStyle(Color.deepBrown)
        .padding(20)
    }

    private var suggestedColors: [String] {
        if let colors = ideas.current?.colors, colors.count == 4 { return colors }
        return mood?.palette ?? Mood.defaultPalette
    }

    // MARK: - Small views

    private func barButton(_ icon: String, isOn: Bool = false, label: String,
                           action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 44, height: 44)
                .background(isOn ? Color.starYellow : .clear, in: Circle())
                .shadow(color: .starYellow.opacity(isOn ? 0.8 : 0), radius: 10)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.deepBrown)
        .accessibilityLabel(label)
    }

    private func handle(_ icon: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring) { action() }
        } label: {
            Image(systemName: icon)
                .font(.caption.bold())
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .foregroundStyle(Color.softBrown)
    }

    private func pageThumbnail(_ index: Int) -> some View {
        let drawing = index == currentPage ? canvas.drawing : pages[index]
        return Image(uiImage: drawing.image(from: canvas.bounds, scale: 0.3))
            .resizable()
            .scaledToFit()
            .frame(width: 90, height: 120)
            .background(Color.paper, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions

    private func openPage(_ index: Int) {
        pages[currentPage] = canvas.drawing
        currentPage = index
        canvas.drawing = pages[index]
        redoStack.removeAll()
    }

    private func addPage() {
        pages.append(PKDrawing())
        openPage(pages.count - 1)
    }

    private func deletePage() {
        guard pages.count > 1 else { return }
        pages.remove(at: currentPage)
        currentPage = max(0, currentPage - 1)
        canvas.drawing = pages[currentPage]
        redoStack.removeAll()
    }

    private func undo() {
        guard let last = canvas.drawing.strokes.popLast() else { return }
        redoStack.append(last)
    }

    private func redo() {
        guard let stroke = redoStack.popLast() else { return }
        canvas.drawing.strokes.append(stroke)
    }
}

/// A vertical slider like the one in the design.
struct VerticalSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    private let knob: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let track = geo.size.height - knob
            let progress = (value - range.lowerBound) / (range.upperBound - range.lowerBound)

            ZStack(alignment: .top) {
                Capsule().fill(Color.softBrown.opacity(0.3))
                Capsule().fill(.white)
                    .frame(height: knob)
                    .offset(y: track * (1 - progress))
            }
            .gesture(DragGesture(minimumDistance: 0).onChanged { drag in
                let p = 1 - min(max((drag.location.y - knob / 2) / track, 0), 1)
                value = range.lowerBound + p * (range.upperBound - range.lowerBound)
            })
        }
        .frame(width: 30, height: 150)
    }
}

#Preview {
    NavigationStack { DrawingView(mood: .confused) }
}
