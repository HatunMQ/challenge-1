//
//  page1-aliah.swift
//  ch1
//
//  Created by Aliah on 11/05/1448 AH.
//
import SwiftUI

extension Color {
    static let brownText = Color(red: 0.42, green: 0.27, blue: 0.18)
    static let sparkleYellow = Color(red: 0.97, green: 0.80, blue: 0.40)
}

struct page1_aliah: View {

    /// Called when the user taps Start: the app goes to the Home page.
    var onStart: () -> Void = {}

    // Flips once when the page appears, which starts the stars pulsing
    @State private var pulse = false

    // خليها false لو النجوم موجودة أصلاً داخل صورة الباكقراوند
    private let showSparkles = true

    // مواقع النجوم كنسبة من حجم الشاشة (x, y)
    private let sparkles: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.37, 0.29, 44),
        (0.59, 0.41, 44),
        (0.10, 0.46, 40),
        (0.81, 0.70, 44),
        (0.33, 0.76, 44)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {

                // النجوم
                if showSparkles {
                    ForEach(sparkles.indices, id: \.self) { i in
                        pulsingSparkle(size: sparkles[i].size, index: i)
                            .position(
                                x: geo.size.width * sparkles[i].x,
                                y: geo.size.height * sparkles[i].y
                            )
                    }
                }

                // النص
                // "soul" and "relax" are marked, so two more stars can be placed next to those words
                VStack(alignment: .leading, spacing: 28) {
                    Text("Hey, creative \(Text("soul").customAttribute(StarAnchor(name: "soul")))!")
                        .font(.system(size: 72, weight: .regular))

                    Text("A little space to draw, \(Text("relax").customAttribute(StarAnchor(name: "relax"))), and just be you.")
                        .font(.system(size: 48, weight: .regular))
                        .lineSpacing(6)
                }
                .overlayPreferenceValue(Text.LayoutKey.self) { layouts in
                    GeometryReader { proxy in
                        let words = markedWords(in: layouts, proxy: proxy)
                        if showSparkles {
                            // Above the word "soul", on its right
                            if let soul = words["soul"] {
                                pulsingSparkle(size: 40, index: 5)
                                    .position(x: soul.rect.maxX, y: soul.rect.minY)
                            }
                            // Under the word "relax": in line with it, but below the whole sentence,
                            // so the star doesn't sit on the text of the next line
                            if let relax = words["relax"] {
                                pulsingSparkle(size: 36, index: 6)
                                    .position(x: relax.rect.midX, y: relax.blockBottom + 50)
                            }
                        }
                    }
                }
                .foregroundStyle(Color.brownText)
                .frame(maxWidth: geo.size.width * 0.72, alignment: .leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, geo.size.width * 0.12)

                // زر Start تحت يمين
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            onStart()
                        } label: {
                            Text("Start")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Color.brownText)
                                .frame(width: 290, height: 95)
                                .background(Capsule().fill(Color.white.opacity(0.35)))
                                .overlay(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
                                .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
                        }
                    }
                    .padding(.trailing, 60)
                    .padding(.bottom, 60)
                }
            }
        }
        // صورة الباكقراوند
        .background(
            Image("back")
                .resizable()
                .scaledToFill()
                .scaleEffect(1.06)      // يخفي الزوايا المدورة
                .ignoresSafeArea()
        )
        .onAppear { pulse = true }
    }

    /// A star that pulses: it grows, glows and fades back, forever.
    /// Each star has its own speed and starts a bit later (by its index), so they don't beat together.
    private func pulsingSparkle(size: CGFloat, index: Int) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: size, weight: .ultraLight))
            .foregroundStyle(Color.sparkleYellow)
            .scaleEffect(pulse ? 1.2 : 0.75)
            .opacity(pulse ? 1 : 0.45)
            .shadow(color: Color.sparkleYellow.opacity(pulse ? 0.9 : 0.1), radius: pulse ? 14 : 2)
            .animation(
                .easeInOut(duration: 1.3 + Double(index) * 0.2)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.3),
                value: pulse
            )
    }

    /// Where a marked word ended up on screen, and where the bottom of its text is.
    private struct MarkedWord {
        let rect: CGRect
        let blockBottom: CGFloat
    }

    /// Finds the marked words on screen (so the stars follow the text on any device).
    private func markedWords(in layouts: [Text.LayoutKey.AnchoredLayout], proxy: GeometryProxy) -> [String: MarkedWord] {
        var words: [String: MarkedWord] = [:]
        for anchored in layouts {
            let origin = proxy[anchored.origin]

            // The bottom of the last line of this text
            let blockBottom = anchored.layout
                .map { $0.typographicBounds.rect.maxY }
                .max() ?? 0

            for line in anchored.layout {
                for run in line {
                    if let marker = run[StarAnchor.self] {
                        words[marker.name] = MarkedWord(
                            rect: run.typographicBounds.rect.offsetBy(dx: origin.x, dy: origin.y),
                            blockBottom: blockBottom + origin.y
                        )
                    }
                }
            }
        }
        return words
    }
}

/// Marks a word in the welcome text, so its place on screen can be found.
private struct StarAnchor: TextAttribute {
    let name: String
}

#Preview {
    page1_aliah()
}
