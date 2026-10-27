// xcode: set sdk=iOS

import SwiftUI

struct Page13: View {
    let drawing: UIImage

    @State private var drawnBecause: String = ""
    @State private var noticedToday: String = ""
    @State private var showPopup = false
    @FocusState private var focusedField: Field?
   enum Field { case because, noticed }

    private let goldBorder = Color(red: 0.93, green: 0.78, blue: 0.40)
    private let placeholderColor = Color(red: 0.47, green: 0.42, blue: 0.33)
    private let cardColor = Color(red: 0.96, green: 0.95, blue: 0.93)

    var onNext: (String, UIImage) -> Void = { _, _ in }

    // MARK: - Body (الصفحة + النافذة)
    var body: some View {
        ZStack {
            content
                .blur(radius: showPopup ? 14 : 0)
                .disabled(showPopup)

            if showPopup {
                Page14 { name, signature in
                    onNext(name, signature)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showPopup)
    }

    // MARK: - محتوى الصفحة
    private var content: some View {
        VStack(spacing: 0) {
            header

            questionCard(
                question: "What do you think your drawing expresses?",
                placeholder: "I drew this because",
                text: $drawnBecause,
                field: .because,
                editorHeight: 190
            )
            .padding(.top, 26)

            questionCard(
                question: "Did you discover something while drawing?",
                placeholder: "Today I noticed that…",
                text: $noticedToday,
                field: .noticed,
                editorHeight: 130
            )
            .padding(.top, 90)

            Spacer()

            nextButton
        }
        .padding(.horizontal, 52)
        .padding(.top, 20)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("rere")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .onTapGesture { focusedField = nil }
    }

    // MARK: - Header
    private var header: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 34) {
                Image(uiImage: drawing)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 86, height: 134)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .frame(width: 178, height: 146)
                    .background(
                        RoundedRectangle(cornerRadius: 24).fill(cardColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(goldBorder, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 10) {
                    Text("understand yourself")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                    Text("No right answers . Just notice")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(placeholderColor)
                }
                Spacer()
            }

            // Skip: يفتح Page14 بدون حفظ
            Button(action: { showPopup = true }) {
                Text("Skip")
                    .font(.system(size: 20))
                    .underline()
                    .foregroundColor(.black)
            }
        }
    }

    // MARK: - Question card
    private func questionCard(
        question: String,
        placeholder: String,
        text: Binding<String>,
        field: Field,
        editorHeight: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(question)
                .font(.system(size: 24))
                .foregroundColor(.black)
                .padding(.leading, 8)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 34)
                    .fill(cardColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 34)
                            .stroke(goldBorder, lineWidth: 1)
                    )

                TextEditor(text: text)
                    .focused($focusedField, equals: field)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .font(.system(size: 22))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(placeholderColor)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 26)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: editorHeight)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 36)
                .fill(cardColor.opacity(0.9))
                .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 10)
        )
    }

    // MARK: - Next: يحفظ ثم يفتح Page14
    private var nextButton: some View {
        HStack {
            Spacer()
            Button(action: {
                saveAnswers()
                showPopup = true
            }) {
                Text("Next")
                    .font(.system(size: 17))
                    .foregroundColor(.black)
                    .frame(width: 178, height: 60)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.89, green: 0.86, blue: 0.84))
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.6), lineWidth: 1))
            }
        }
    }

    // MARK: - الحفظ
    private func saveAnswers() {
        UserDefaults.standard.set(drawnBecause, forKey: "drawnBecause")
        UserDefaults.standard.set(noticedToday, forKey: "noticedToday")
    }
}

#Preview {
    Page13(drawing: UIImage(named: "matchstick") ?? UIImage())
}
