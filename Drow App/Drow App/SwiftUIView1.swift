//
//  SwiftUIView1.swift
//  First app
//
//  Created by Aseel Suliman Alfayez on 09/05/1448 AH.
//

import SwiftUI

/// A single drawing shown in the gallery carousel.
struct DrawingItem: Identifiable {
    /// Stable id so selection survives view re-creation (unique even if two items share an image).
    let id: String
    let title: String
    let imageName: String
    /// Answer shown on the back of the card: "What do you think your drawing expresses?"
    let expresses: String
    /// Answer shown on the back of the card: "Did you discover something while drawing?"
    let discovery: String
}

struct SwiftUIView1: View {

    private let gold = Color(red: 0.62, green: 0.50, blue: 0.24)
    private let cream = Color(red: 0.96, green: 0.92, blue: 0.82)

    @State private var drawings: [DrawingItem] = [
        DrawingItem(
            id: "scream",
            title: "The Scream",
            imageName: "scream",
            expresses: "Anxiety and fear. The swirling sky and the figure holding its face show how overwhelming a feeling can become.",
            discovery: "I noticed that bold, wavy lines can carry emotion even without any detail in the face."
        ),
        DrawingItem(
            id: "match",
            title: "Match",
            imageName: "match",
            expresses: "A spark of hope. A tiny flame can light up a dark place and change the whole mood.",
            discovery: "Layering warm colors next to cool ones makes the fire feel like it is glowing."
        ),
        DrawingItem(
            id: "monalisa",
            title: "Mona Lisa",
            imageName: "monalisa",
            expresses: "Calm and mystery. The quiet smile makes you wonder what she is thinking.",
            discovery: "Soft shading instead of hard outlines makes a face look more alive and natural."
        ),
        // Extra drawing (reuses an asset) for testing delete
        DrawingItem(
            id: "scream-test",
            title: "Test Sketch",
            imageName: "scream",
            expresses: "A test sketch to try out the app, expressing curiosity about how everything works.",
            discovery: "I discovered that practicing every day makes drawing easier and more fun."
        )
    ]

    /// Ids of the cards currently flipped to show their back side.
    @State private var flippedIDs: Set<String> = []
    @State private var showDeleteConfirmation = false
    @State private var searchText = ""
    // Start on the middle card
    @State private var selectedID: String? = "match"
    @State private var showMenu = false
    // Opens the mood page; `withScenario` decides if the drawing page shows an idea
    @State private var goToMood = false
    @State private var withScenario = true

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

                carousel
                    .padding(.top, 40)

                pageDots
                    .padding(.top, 24)

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
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $goToMood) {
            // Closing the drawing page sets goToMood to false, which pops back to this page
            MoodView(withScenario: withScenario, onClose: { goToMood = false })
        }
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
                    .foregroundStyle(gold)
                Text("25")
                    .font(.title3)
                    .foregroundStyle(gold)
            }
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
                    // Start on the middle card so there are cards on both sides
                    guard !drawings.isEmpty else { return }
                    let middleID = drawings[drawings.count / 2].id
                    selectedID = middleID
                    scrollProxy.scrollTo(middleID, anchor: .center)
                }
                }

                actionBar
                    .padding(.top, 8)
            }
        }
        .frame(height: 640)
    }

    private var filteredDrawings: [DrawingItem] {
        searchText.isEmpty
            ? drawings
            : drawings.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    /// Removes the selected drawing and moves the selection to a neighbouring card.
    private func deleteSelectedDrawing() {
        guard let index = drawings.firstIndex(where: { $0.id == selectedID }) else { return }
        withAnimation {
            drawings.remove(at: index)
            selectedID = drawings.isEmpty ? nil : drawings[min(index, drawings.count - 1)].id
        }
    }

    /// A card that flips between the drawing (front) and its notes (back).
    private func card(for item: DrawingItem) -> some View {
        let isFlipped = flippedIDs.contains(item.id)

        return ZStack {
            cardFront(for: item)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            cardBack(for: item)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
    }

    /// The corner arrow that flips the card over (and back).
    private func flipButton(for item: DrawingItem) -> some View {
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
    private func cardBack(for item: DrawingItem) -> some View {
        VStack(spacing: 14) {
            Text("What do you think your drawing expresses?")
                .font(.system(size: 13))
                .foregroundStyle(.black)
            answerBox(item.expresses, highlighted: true)

            Text("Did you discover something while drawing?")
                .font(.system(size: 13))
                .foregroundStyle(.black)
                .padding(.top, 8)
            answerBox(item.discovery, highlighted: false)
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
    private func answerBox(_ text: String, highlighted: Bool) -> some View {
        Text(text)
            .font(.system(size: 14))
            .foregroundStyle(.black)
            .multilineTextAlignment(.leading)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(red: 0.97, green: 0.95, blue: 0.90), in: .rect(cornerRadius: 28))
            .overlay {
                if highlighted {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color(red: 0.35, green: 0.35, blue: 0.95), lineWidth: 4)
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
    }

    /// Front of the card: a framed drawing with a canvas inside.
    private func cardFront(for item: DrawingItem) -> some View {
        let isSelected = selectedID == item.id

        return Color.clear
            .overlay {
                Image(item.imageName)
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
    private func titleBadge(for item: DrawingItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.system(size: 10))
                .foregroundStyle(.black)
            Image(systemName: "signature")
                .font(.system(size: 30))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(8)
        .frame(width: 80, height: 82, alignment: .topLeading)
        .background(.white.opacity(0.85), in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(.gray.opacity(0.4), lineWidth: 1)
        }
    }

    /// Edit and delete buttons below the selected card.
    private var actionBar: some View {
        HStack(spacing: 28) {
            Button {
                // Edit action
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
    SwiftUIView1()
}
