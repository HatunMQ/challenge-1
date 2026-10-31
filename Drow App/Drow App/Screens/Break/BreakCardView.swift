import SwiftUI

struct BreakCardView: View {

    var minuteOptions: [Int] = [1, 5, 10, 15, 20, 30, 45, 60]

    var onSkip: () -> Void = {}

    var onTakeBreak: (_ minutes: Int) -> Void = { _ in }

    @State private var selectedMinutes: Int = 5

    var body: some View {
        ZStack(alignment: .topTrailing) {

            VStack(spacing: 20) {
                Spacer(minLength: 10)

                Text("PASS")
                    .font(.system(size: 76, weight: .regular))
                    .foregroundStyle(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text("YOU NEED TO RELAX!")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(.black)

                Picker("Minutes", selection: $selectedMinutes) {
                    ForEach(minuteOptions, id: \.self) { minute in
                        Text("\(minute) min").tag(minute)
                    }
                }
                .pickerStyle(.menu)
                .tint(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(glassCapsule)
                .padding(.horizontal, 36)

                Button {
                    onTakeBreak(selectedMinutes)
                } label: {
                    Text("Take Break")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 130, height: 40)
                        .background(glassCapsule)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 16)
            }
            .frame(maxWidth: .infinity)

            Button(action: onSkip) {
                Text("Skip")
                    .font(.system(size: 12))
                    .underline()
                    .foregroundStyle(.black)
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
            .padding(.trailing, 18)
        }
        .frame(width: 320, height: 380)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.88, green: 0.79, blue: 0.62),
                    Color(red: 0.75, green: 0.64, blue: 0.51)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 30, y: 12)
    }

    private var glassCapsule: some View {
        Capsule()
            .fill(.white.opacity(0.18))
            .overlay(
                Capsule().strokeBorder(.white.opacity(0.55), lineWidth: 1.2)
            )
            .shadow(color: .black.opacity(0.15), radius: 4, y: 3)
    }
}

#Preview {
    ZStack {
        Color(red: 0.99, green: 0.98, blue: 0.97)
            .ignoresSafeArea()

        BreakCardView()
    }
}
