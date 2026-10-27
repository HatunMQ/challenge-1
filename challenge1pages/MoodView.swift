import SwiftUI

struct MoodView: View {
    @State private var mood: Mood?
    @State private var sound: Sound?
    @State private var breakMinutes = 15.0
    @State private var noBreak = false
    @State private var showSkipAlert = false
    @State private var goToCanvas = false
    private let player = SoundPlayer.shared

    var body: some View {
        ZStack {
            AuraBackground()

            VStack(spacing: 36) {
                Text("How do you feel?")
                    .font(.system(size: 44, weight: .heavy))
                    .padding(.top, 70)

                HStack(spacing: 20) {
                    ForEach(Mood.allCases) { item in
                        MoodButton(mood: item, isSelected: mood == item) {
                            withAnimation(.spring(duration: 0.35)) { mood = item }
                        }
                    }
                }

                VStack(spacing: 18) {
                    Text("Choose sound for relaxation:")
                        .font(.system(size: 34, weight: .heavy))

                    ForEach(Sound.allCases) { item in
                        SoundButton(sound: item, isSelected: sound == item) { select(item) }
                    }
                }
                .padding(.horizontal, 60)

                BreakPicker(minutes: $breakMinutes, noBreak: $noBreak)
                    .padding(.horizontal, 60)

                Spacer()

                Button { goToCanvas = true } label: {
                    Text("Next").frame(minWidth: 90)
                }
                .font(.system(size: 20, weight: .semibold))
                .buttonStyle(.glass)
                .controlSize(.extraLarge)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding([.trailing, .bottom], 40)
            }
            .foregroundStyle(Color.deepBrown)
        }
        // Skip sits in the top-right corner, like a toolbar button
        .overlay(alignment: .topTrailing) {
            Button { showSkipAlert = true } label: {
                Text("Skip").frame(minWidth: 90)
            }
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(Color.deepBrown)
            .buttonStyle(.glass)
            .controlSize(.extraLarge)
            .padding(.top, 24)
            .padding(.trailing, 40)
        }
        .alert("Skip this step?", isPresented: $showSkipAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Skip") {
                mood = nil
                noBreak = true
                goToCanvas = true
            }
        } message: {
            Text("You can start drawing right away without choosing a mood, a sound, or a break time.")
        }
        .navigationDestination(isPresented: $goToCanvas) {
            DrawingView(mood: mood, breakMinutes: noBreak ? nil : Int(breakMinutes))
        }
    }

    /// Plays the tapped sound, or stops it if tapped again.
    private func select(_ item: Sound) {
        withAnimation {
            if sound == item {
                sound = nil
                player.stop()
            } else {
                sound = item
                player.play(item)
            }
        }
    }
}

/// A slider to choose when to take a break, with a "No break" checkbox.
struct BreakPicker: View {
    @Binding var minutes: Double
    @Binding var noBreak: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Break reminder", systemImage: "timer")
                    .font(.system(size: 22, weight: .heavy))
                Spacer()
                Text(noBreak ? "Off" : "\(Int(minutes)) min")
                    .font(.system(size: 20, weight: .semibold).monospacedDigit())
                    .contentTransition(.numericText())
            }

            Slider(value: $minutes, in: 5...30, step: 5) {
                Text("Break after")
            } minimumValueLabel: {
                Text("5").font(.footnote)
            } maximumValueLabel: {
                Text("30").font(.footnote)
            }
            .tint(.softOrange)
            .disabled(noBreak)
            .opacity(noBreak ? 0.4 : 1)

            Button {
                withAnimation { noBreak.toggle() }
            } label: {
                Label("I don't want a break", systemImage: noBreak ? "checkmark.square.fill" : "square")
                    .font(.system(size: 17, weight: .medium))
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(noBreak ? .isSelected : [])
        }
        .foregroundStyle(Color.deepBrown)
        .padding(22)
        .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 28))
        .animation(.easeInOut, value: minutes)
    }
}

struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(mood.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 92, height: 92)
                Text(mood.rawValue)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.softBrown)
            }
            .frame(width: 150, height: 170)
            .background(isSelected ? Color.white : .appCream, in: Ellipse())
            .overlay(Ellipse().stroke(isSelected ? mood.color : .white, lineWidth: isSelected ? 4 : 2))
            .shadow(color: isSelected ? mood.color.opacity(0.8) : .black.opacity(0.12), radius: isSelected ? 22 : 10)
            .scaleEffect(isSelected ? 1.08 : 1)
        }
        .buttonStyle(.plain)
    }
}

struct SoundButton: View {
    let sound: Sound
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(sound.rawValue)
                    .font(.system(size: 26))
                Text(sound.subtitle)
                    .font(.system(size: 15))
                    .opacity(0.85)
            }
                .foregroundStyle(isSelected ? Color.deepBrown : .white)
                .frame(maxWidth: .infinity, minHeight: 86)
                .background(isSelected ? Color.starYellow : .gold.opacity(0.85), in: Capsule())
                .shadow(color: isSelected ? .starYellow.opacity(0.8) : .clear, radius: 18)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { MoodView() }
}
