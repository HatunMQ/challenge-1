import SwiftUI

/// The break screens, shown on top of the drawing page so the drawing is kept:
/// the pass card first, then Deep Breath if the user takes a break.
struct BreakFlowView: View {
    /// Called when the user skips or the breathing time ends. The drawing page closes this screen.
    var onFinish: () -> Void

    /// Break length chosen on the pass card. nil means the card is still showing.
    @State private var breathMinutes: Int?

    var body: some View {
        ZStack {
            if let breathMinutes {
                Deep_Breath(duration: breathMinutes * 60, onSkip: onFinish)
                    .transition(.opacity)
            } else {
                BreakCardView(
                    onSkip: onFinish,
                    onTakeBreak: { minutes in breathMinutes = minutes }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Image(.back)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: breathMinutes)
    }
}

#Preview {
    BreakFlowView(onFinish: {})
}
