//
//  SwiftUIView1.swift
//  First app
//
//  Created by Aseel Suliman Alfayez on 09/05/1448 AH.
//

import SwiftUI
import SwiftData

struct SwiftUIView1: View {

    private let gold = Color(red: 0.62, green: 0.50, blue: 0.24)
    private let cream = Color(red: 0.96, green: 0.92, blue: 0.82)

    @Environment(\.modelContext) private var modelContext
    /// The saved drawings, newest first.
    @Query(sort: \SavedDrawing.createdAt, order: .reverse) private var drawings: [SavedDrawing]

    /// Ids of the cards currently flipped to show their back side.
    @State private var flippedIDs: Set<String> = []
    @State private var showDeleteConfirmation = false
    @State private var searchText = ""
    // The id of the card in the middle of the carousel
    @State private var selectedID: String?
    // True once the carousel has started on the middle drawing (done only the first time)
    @State private var didStartInMiddle = false
    @State private var showMenu = false
    // Opens the mood page; `withScenario` decides if the drawing page shows an idea
    @State private var goToMood = false
    @State private var withScenario = true
    // The drawing being edited; nil when starting a new one
    @State private var editingDrawing: SavedDrawing?
    // The drawing whose name and signature window is open (opened by tapping the badge on the card)
    @State private var badgeEditing: SavedDrawing?
    // Which answer on the back of a card is being typed in (nil = none)
    @FocusState private var focusedAnswer: String?

    /// The days the user saved a drawing. Kept apart from the drawings, so deleting one keeps the streak.
    @AppStorage(StreakStore.key) private var drawingDaysRaw = ""

    /// Days in a row with a saved drawing (one missed day is forgiven).
    private var streak: Int {
        Streak.current(dates: StreakStore.days(from: drawingDaysRaw))
    }

    /// Adds the days of drawings saved before this feature existed (does nothing if already there).
    private func addExistingDrawingDays() {
        let updated = StreakStore.adding(drawings.map(\.createdAt), to: drawingDaysRaw)
        if updated != drawingDaysRaw { drawingDaysRaw = updated }
    }

    private var currentIndex: Int {
        drawings.firstIndex { $0.id == selectedID } ?? 0
    }

    var body: some View {
        ZStack(alignment: .top) {
            background

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                searchBar
                    .padding(.top, 70)

                if drawings.isEmpty {
                    emptyState
                        .padding(.top, 200)
                } else {
                    carousel
                        .padding(.top, 40)

                    pageDots
                        .padding(.top, 24)
                }

                Spacer()
            }

            if showMenu {
                drawMenu
                    .frame(width: 340)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 60)
                    .padding(.top, 70)
            }
        }
        // While the name and signature window is open, the page behind is blurred and can't be touched
        .blur(radius: badgeEditing == nil ? 0 : 14)
        .disabled(badgeEditing != nil)
        .overlay {
            if let drawing = badgeEditing {
                ZStack {
                    // Tapping outside the window closes it without saving
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture { badgeEditing = nil }

                    Page14(
                        onContinue: { name, signature, strokes in
                            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            drawing.updateNameAndSignature(
                                title: trimmed.isEmpty ? "Untitled" : trimmed,
                                signature: signature,
                                signatureStrokes: strokes
                            )
                            badgeEditing = nil
                        },
                        initialName: drawing.title,
                        initialStrokes: drawing.signatureStrokes
                    )
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: badgeEditing?.id)
        .onAppear(perform: addExistingDrawingDays)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $goToMood) {
            // Closing the drawing page sets goToMood to false, which pops back to this page
            MoodView(withScenario: withScenario, editing: editingDrawing, onClose: { goToMood = false })
        }
    }

    // MARK: - Empty state

    /// Shown until the first drawing is saved.
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "pencil.and.scribble")
                .font(.system(size: 44))
            Text("No drawings yet")
                .font(.title2.weight(.semibold))
            Text("Tap + to start your first one")
                .font(.body)
        }
        .foregroundStyle(gold)
    }

    // MARK: - Background

    private var background: some View {
        // Overlay inside a clear color so the filled image doesn't affect layout size
        Color.clear
            .overlay {
                Image("background")
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .ignoresSafeArea()
    }

    // MARK: - Top bar (streak + add button)

    private var topBar: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Streak.flameColor(for: streak))
                    .animation(.easeInOut, value: streak)
                Text("\(streak)")
                    .font(.title3)
                    .foregroundStyle(gold)
                    .contentTransition(.numericText())
                    .animation(.easeInOut, value: streak)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Streak: \(streak) days in a row")
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.white.opacity(0.5), in: .capsule)

            Spacer()

            Button {
                withAnimation { showMenu.toggle() }
            } label: {
                Image(systemName: "plus")
                    .font(.title3)
                    .foregroundStyle(gold)
                    .frame(width: 48, height: 48)
                    .background(.white.opacity(0.5), in: .circle)
            }
        }
    }

    // MARK: - Menu under the plus button

    private var drawMenu: some View {
        VStack(spacing: 8) {
            Button {
                showMenu = false
                withScenario = false
                editingDrawing = nil
                goToMood = true
            } label: {
                Text("free draw")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(gold, in: .capsule)
            }

            Button {
                showMenu = false
                withScenario = true
                editingDrawing = nil
                goToMood = true
            } label: {
                Text("Draw with scenario")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(.gray.opacity(0.2), in: .capsule)
            }
        }
        .padding(4)
        .background(.white.opacity(0.35), in: .rect(cornerRadius: 4))
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title3)
            TextField("Search", text: $searchText)
                .frame(width: 90)
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(.white.opacity(0.5), in: .capsule)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
    }

    // MARK: - Carousel

    private var carousel: some View {
        GeometryReader { proxy in
            let cardWidth = proxy.size.width * 0.4
            let sideInset = (proxy.size.width - cardWidth) / 2

            VStack(spacing: 0) {
                ScrollViewReader { scrollProxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 24) {
                        ForEach(filteredDrawings) { item in
                            card(for: item)
                                .frame(width: cardWidth)
                                .scrollTransition(axis: .horizontal) { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.85)
                                        .opacity(phase.isIdentity ? 1 : 0.9)
                                }
                                .id(item.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.horizontal, sideInset, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $selectedID, anchor: .center)
                .scrollIndicators(.hidden)
                .onAppear {
                    // The first time Home opens, start on the middle drawing,
                    // so there are drawings on both sides to browse
                    guard !didStartInMiddle, !drawings.isEmpty else { return }
                    didStartInMiddle = true
                    let middleID = drawings[drawings.count / 2].id
                    selectedID = middleID
                    scrollProxy.scrollTo(middleID, anchor: .center)
                }
                .onChange(of: drawings.count) { oldCount, newCount in
                    // A new drawing was saved: show it (the newest one is first)
                    guard newCount > oldCount, let newestID = drawings.first?.id else { return }
                    selectedID = newestID
                    scrollProxy.scrollTo(newestID, anchor: .center)
                }
                }

                actionBar
                    .padding(.top, 8)
            }
        }
        .frame(height: 640)
    }

    private var filteredDrawings: [SavedDrawing] {
        searchText.isEmpty
            ? drawings
            : drawings.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    /// Opens the selected drawing for editing, starting from the mood page like a new drawing.
    private func editSelectedDrawing() {
        guard let selected = drawings.first(where: { $0.id == selectedID }) else { return }
        editingDrawing = selected
        withScenario = false   // The drawing already exists, so no new idea is shown
        showMenu = false
        goToMood = true
    }

    /// Removes the selected drawing and moves the selection to a neighbouring card.
    private func deleteSelectedDrawing() {
        guard let index = drawings.firstIndex(where: { $0.id == selectedID }) else { return }
        // Work out the neighbour before deleting, because the list changes after the delete
        let remaining = drawings.filter { $0.id != selectedID }
        let nextID = remaining.isEmpty ? nil : remaining[min(index, remaining.count - 1)].id
        withAnimation {
            modelContext.delete(drawings[index])
            selectedID = nextID
        }
    }

    /// A card that flips between the drawing (front) and its notes (back).
    private func card(for item: SavedDrawing) -> some View {
        let isFlipped = flippedIDs.contains(item.id)

        return ZStack {
            cardFront(for: item)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .allowsHitTesting(!isFlipped)   // The hidden side must not catch touches
            cardBack(for: item)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                .allowsHitTesting(isFlipped)
        }
    }

    /// The corner arrow that flips the card over (and back).
    private func flipButton(for item: SavedDrawing) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.5)) {
                if flippedIDs.contains(item.id) {
                    flippedIDs.remove(item.id)
                } else {
                    flippedIDs.insert(item.id)
                }
            }
        } label: {
            Image(systemName: "arrow.turn.right.down")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(red: 0.3, green: 0.2, blue: 0.15))
                // Bigger tap area; the negative padding keeps the arrow where it was
                .padding(10)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.top, -5)
        .padding(.trailing, -7)
    }

    /// Back of the card: two questions with their answers.
    private func cardBack(for item: SavedDrawing) -> some View {
        VStack(spacing: 14) {
            Text("What do you think your drawing expresses?")
                .font(.system(size: 13))
                .foregroundStyle(.black)
            answerBox(Bindable(item).expresses, key: "\(item.id)-expresses", highlighted: true)

            Text("Did you discover something while drawing?")
                .font(.system(size: 13))
                .foregroundStyle(.black)
                .padding(.top, 8)
            answerBox(Bindable(item).discovery, key: "\(item.id)-discovery", highlighted: false)
        }
        .padding(EdgeInsets(top: 44, leading: 16, bottom: 16, trailing: 16))
        .frame(height: 520)
        .background(cream, in: .rect(cornerRadius: 28))
        .overlay(alignment: .topTrailing) {
            flipButton(for: item)
        }
        .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }

    /// A rounded box holding an answer; the highlighted one gets the blue outline.
    /// An answer the user can tap and edit. Pressing Enter closes the keyboard, and the change is saved.
    private func answerBox(_ text: Binding<String>, key: String, highlighted: Bool) -> some View {
        TextEditor(text: text)
            .focused($focusedAnswer, equals: key)
            .scrollContentBackground(.hidden)
            .font(.system(size: 14))
            .foregroundStyle(.black)
            .padding(11)   // The editor adds its own space, so the total matches the old 16
            .overlay(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text("Tap to write…")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .padding(16)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(red: 0.97, green: 0.95, blue: 0.90), in: .rect(cornerRadius: 28))
            .overlay {
                if highlighted {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color(red: 0.35, green: 0.35, blue: 0.95), lineWidth: 4)
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            .onChange(of: text.wrappedValue) { _, newValue in
                // Enter: remove the new line and close the keyboard
                if newValue.contains("\n") {
                    text.wrappedValue = newValue.replacingOccurrences(of: "\n", with: "")
                    focusedAnswer = nil
                }
            }
            .onChange(of: focusedAnswer) { oldValue, newValue in
                // The keyboard closed on this answer: save it now
                if oldValue == key && newValue != key {
                    try? modelContext.save()
                }
            }
    }

    /// Front of the card: a framed drawing with a canvas inside.
    private func cardFront(for item: SavedDrawing) -> some View {
        let isSelected = selectedID == item.id

        return Color.clear
            .overlay {
                Image(uiImage: item.image)
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(.rect(cornerRadius: 22))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color(red: 0.35, green: 0.35, blue: 0.95), lineWidth: 4)
                }
            }
            .overlay(alignment: .bottomLeading) {
                titleBadge(for: item)
                    .padding(12)
            }
            // Extra room on top so the flip button sits in the frame, not over the drawing
            .padding(EdgeInsets(top: 20, leading: 16, bottom: 16, trailing: 16))
            .frame(height: 520)
            .background(cream, in: .rect(cornerRadius: 28))
            .overlay(alignment: .topTrailing) {
                flipButton(for: item)
            }
            .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }

    /// Small box on the drawing showing its name and signature.
    private func titleBadge(for item: SavedDrawing) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.system(size: 10))
                .foregroundStyle(.black)
            // The user's own signature (nothing is shown if they did not sign)
            Group {
                if let signature = item.signature {
                    Image(uiImage: signature)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 34, alignment: .trailing)
        }
        .padding(8)
        .frame(width: 80, height: 82, alignment: .topLeading)
        .background(.white.opacity(0.85), in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.gray.opacity(0.4), lineWidth: 1)
        }
        // Tapping the badge opens the name and signature window, for a quick change
        .contentShape(.rect(cornerRadius: 14))
        .onTapGesture { badgeEditing = item }
    }

    /// Edit and delete buttons below the selected card.
    private var actionBar: some View {
        HStack(spacing: 28) {
            Button {
                editSelectedDrawing()
            } label: {
                Image(systemName: "pencil.tip.crop.circle")
                    .font(.title2)
            }
            Button {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .font(.title3)
            }
        }
        .alert("Delete this sketch?", isPresented: $showDeleteConfirmation) {
            Button("No", role: .cancel) { }
            Button("Yes", role: .destructive) { deleteSelectedDrawing() }
        }
        .foregroundStyle(Color(red: 0.3, green: 0.2, blue: 0.15))
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
        .background(cream, in: .capsule)
        .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
    }

    // MARK: - Page dots

    private var pageDots: some View {
        HStack(spacing: 10) {
            ForEach(drawings.indices, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.black : Color.gray.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.6), in: .capsule)
    }
}

#Preview {
    NavigationStack {
        SwiftUIView1()
    }
    .modelContainer(for: SavedDrawing.self, inMemory: true)
}
