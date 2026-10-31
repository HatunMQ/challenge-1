import SwiftUI

/// A Yes / No question shown as a Liquid Glass card over a dimmed background.
/// The caller decides when to show it (usually with `if isShowing { GlassConfirmDialog(...) }`).
struct GlassConfirmDialog: View {
    let title: String
    var message: String?    // Optional smaller line under the title
    var yesTitle = "Yes"
    var noTitle = "No"
    var onYes: () -> Void
    var onNo: () -> Void

    var body: some View {
        ZStack {
            // Dims the page behind and stops touches from reaching it
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                    if let message {
                        Text(message)
                            .font(.subheadline)
                    }
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.deepBrown)

                GlassEffectContainer(spacing: 16) {
                    HStack(spacing: 16) {
                        Button(action: onNo) {
                            Text(noTitle)
                                .font(.headline)
                                .foregroundStyle(Color.deepBrown)
                                .frame(minWidth: 90)
                        }
                        .buttonStyle(.glass)

                        Button(action: onYes) {
                            Text(yesTitle)
                                .font(.headline)
                                .frame(minWidth: 90)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(Color.gold)
                    }
                    .controlSize(.large)
                }
            }
            .padding(28)
            .frame(maxWidth: 380)
            .glassEffect(.regular, in: .rect(cornerRadius: 32))
        }
    }
}

#Preview {
    ZStack {
        AuraBackground()
        GlassConfirmDialog(title: "Do you want to save the sketch?", onYes: {}, onNo: {})
    }
}
