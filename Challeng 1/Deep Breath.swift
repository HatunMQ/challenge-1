import SwiftUI

struct Deep_Breath: View {
    @Environment(\.dismiss) private var dismiss

    private let duration: Int
    private let onSkip: (() -> Void)?

    let cardColor = Color(red: 0.945, green: 0.925, blue: 0.885)
    let pillColor = Color(red: 0.90, green: 0.88, blue: 0.86)

    @State private var remainingSeconds: Int
    @State private var timer: Timer?
    @State private var startDate = Date()

    private let inhaleTime = 4.0
    private let holdTime   = 2.0
    private let exhaleTime = 4.0
    private var cycleTime: Double { inhaleTime + holdTime + exhaleTime }

    private let waveSize = CGSize(width: 420, height: 70)

    enum Phase { case inhale, hold, exhale }

    init(duration: Int = 300, onSkip: (() -> Void)? = nil) {
        self.duration = duration
        self.onSkip = onSkip
        _remainingSeconds = State(initialValue: duration)
    }

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Spacer()
                Button {
                    skip()
                } label: {
                    Text("Skip")
                        .font(.system(size: 22))
                        .underline()
                        .foregroundColor(.black)
                        .padding(12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 38)
            .padding(.top, 18)

            Text("Deep Breath")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 10)

            HStack {
                Text("Time")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Spacer()
                Text(timeString)
                    .font(.system(size: 17, weight: .regular, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(pillColor)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 22)
            .frame(width: 520, height: 70)
            .background(cardColor)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.15), radius: 14, x: 0, y: 10)
            .padding(.top, 50)

            TimelineView(.animation) { context in
                let state = breathState(at: context.date)

                VStack(spacing: 0) {
                    Spacer()

                    Image(.star)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 520)
                        .scaleEffect(0.92 + 0.08 * breathShape(state.t))

                    Spacer()

                    VStack(spacing: 6) {
                        ZStack {
                            BreathWave()
                                .stroke(Color.black, lineWidth: 1)

                            let p = BreathWave.point(t: state.t, size: waveSize, offset: 0)

                            let edge = min(state.t, 1 - state.t)
                            let f = min(1.0, edge / 0.12)
                            let appear = f * f * (3 - 2 * f)

                            Circle()
                                .fill(Color.black)
                                .frame(width: 14, height: 14)
                                .scaleEffect((0.4 + 0.6 * appear) * (state.phase == .hold ? 1.4 : 1.0))
                                .shadow(color: .black.opacity(0.3), radius: 5)
                                .position(x: p.x, y: p.y)
                                .opacity(appear)
                                .animation(.easeInOut(duration: 0.3), value: state.phase)

                            Text("Hold")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .position(x: waveSize.width / 2, y: waveSize.height * 0.05 - 22)
                                .opacity(state.phase == .hold ? 1 : 0)
                                .animation(.easeInOut(duration: 0.3), value: state.phase)
                        }
                        .frame(width: waveSize.width, height: waveSize.height)
                        .padding(.top, 30)

                        HStack {
                            Text("inhale")
                                .opacity(state.phase == .inhale ? 1 : 0.5)
                            Spacer()
                            Text("Exhale")
                                .opacity(state.phase == .exhale ? 1 : 0.5)
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 440)
                    }
                    .padding(.bottom, 80)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image(.back)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .onAppear { startSession() }
        .onDisappear { timer?.invalidate() }
    }

    private func skip() {
        timer?.invalidate()
        if let onSkip {
            onSkip()
        } else {
            dismiss()
        }
    }

    private func breathState(at date: Date) -> (t: Double, phase: Phase) {
        let elapsed = date.timeIntervalSince(startDate)
            .truncatingRemainder(dividingBy: cycleTime)

        if elapsed < inhaleTime {
            let p = elapsed / inhaleTime
            return (0.5 * smooth(p), .inhale)
        } else if elapsed < inhaleTime + holdTime {
            return (0.5, .hold)
        } else {
            let p = (elapsed - inhaleTime - holdTime) / exhaleTime
            return (0.5 + 0.5 * smooth(p), .exhale)
        }
    }

    private func smooth(_ x: Double) -> Double {
        x * x * (3 - 2 * x)
    }

    private var timeString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startSession() {
        startDate = Date()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                t.invalidate()
                skip()
            }
        }
    }
}

func breathShape(_ t: Double) -> Double {
    0.5 - 0.5 * cos(2 * .pi * t)
}

struct BreathWave: Shape {
    static let offsets: [CGFloat] = [0, 0.18, 0.36]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        for o in Self.offsets {
            let c = Self.controls(size: rect.size, offset: o)

            path.move(to: c.p0)
            path.addCurve(to: c.p1End, control1: c.a1, control2: c.a2)
            path.addCurve(to: c.p2End, control1: c.b1, control2: c.b2)
        }
        return path
    }

    private static func controls(size: CGSize, offset o: CGFloat)
        -> (p0: CGPoint, a1: CGPoint, a2: CGPoint, p1End: CGPoint,
            b1: CGPoint, b2: CGPoint, p2End: CGPoint)
    {
        let w = size.width
        let h = size.height
        let startY = h * (0.55 + o * 0.6)
        let peakY  = h * (0.05 + o * 0.5)
        let endY   = h * (0.6  + o * 0.5)

        return (
            p0:    CGPoint(x: 0,        y: startY),
            a1:    CGPoint(x: w * 0.2,  y: startY),
            a2:    CGPoint(x: w * 0.3,  y: peakY),
            p1End: CGPoint(x: w * 0.5,  y: peakY),
            b1:    CGPoint(x: w * 0.7,  y: peakY),
            b2:    CGPoint(x: w * 0.85, y: endY),
            p2End: CGPoint(x: w,        y: endY)
        )
    }

    static func point(t: Double, size: CGSize, offset o: CGFloat) -> CGPoint {
        let c = controls(size: size, offset: o)

        if t <= 0.5 {
            return bezier(u: CGFloat(t * 2), c.p0, c.a1, c.a2, c.p1End)
        } else {
            return bezier(u: CGFloat((t - 0.5) * 2), c.p1End, c.b1, c.b2, c.p2End)
        }
    }

    private static func bezier(u: CGFloat, _ p0: CGPoint, _ p1: CGPoint,
                               _ p2: CGPoint, _ p3: CGPoint) -> CGPoint {
        let v = 1 - u
        let x = v*v*v * p0.x + 3*v*v*u * p1.x + 3*v*u*u * p2.x + u*u*u * p3.x
        let y = v*v*v * p0.y + 3*v*v*u * p1.y + 3*v*u*u * p2.y + u*u*u * p3.y
        return CGPoint(x: x, y: y)
    }
}

#Preview {
    Deep_Breath()
}
