import SwiftUI

struct Page15: View {
    var onDone: () -> Void = {}

    private let gold = Color(red: 0.97, green: 0.83, blue: 0.45)

    // Only the card: the pages behind it stay visible (blurred by the page that shows this one)
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            card
        }
    }

    // MARK: - الكرت
    private var card: some View {
        ZStack {
            // 1) الكرت الأبيض (أسفل طبقة)
            RoundedRectangle(cornerRadius: 44)
                .fill(Color(red: 0.99, green: 0.98, blue: 0.97))
                .shadow(color: .black.opacity(0.25), radius: 30, x: 0, y: 18)

            // 2) النجوم واللمعة (تحت الكلام)
            HeartBurst(color: gold)
                .frame(width: 120, height: 100)
                .offset(x: -150, y: -150)

            Sparkle(color: gold)
                .frame(width: 36, height: 78)
                .offset(x: -100, y: -18)

            Sparkle(color: gold)
                .frame(width: 34, height: 76)
                .offset(x: -180, y: 55)

            Sparkle(color: gold)
                .frame(width: 34, height: 76)
                .offset(x: 205, y: 50)

            // 3) الكلام (فوق كل شي)
            Text("You did amazing!")
                .font(.system(size: 50, weight: .heavy))
                .foregroundColor(.black)
                .offset(x: 25, y: -105)

            VStack(spacing: 4) {
                Text("we so proud of you")
                Text("for take this time for yourself")
            }
            .font(.system(size: 26, weight: .bold))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .offset(x: 0, y: 25)
        }
        .frame(width: 756, height: 570)
        .onTapGesture { onDone() }
    }
}

// MARK: - نجمة رباعية
struct Sparkle: View {
    var color: Color

    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let c = CGPoint(x: w / 2, y: h / 2)
            var p = Path()
            p.move(to: CGPoint(x: c.x, y: 0))
            p.addQuadCurve(to: CGPoint(x: w, y: c.y), control: CGPoint(x: c.x + 3, y: c.y - 3))
            p.addQuadCurve(to: CGPoint(x: c.x, y: h), control: CGPoint(x: c.x + 3, y: c.y + 3))
            p.addQuadCurve(to: CGPoint(x: 0, y: c.y), control: CGPoint(x: c.x - 3, y: c.y + 3))
            p.addQuadCurve(to: CGPoint(x: c.x, y: 0), control: CGPoint(x: c.x - 3, y: c.y - 3))
            ctx.fill(p, with: .color(color))
            ctx.stroke(p, with: .color(color.opacity(0.7)), lineWidth: 1)
        }
    }
}

// MARK: - لمعة القلب والخطوط
struct HeartBurst: View {
    var color: Color

    var body: some View {
        ZStack {
            // الخطوط (من اليسار لليمين)
            burstLine(angle: -75, length: 22, x: -42, y: 22)
            burstLine(angle: -50, length: 34, x: -22, y: 6)
            burstLine(angle: -15, length: 30, x: 0, y: -4)
            burstLine(angle: 15, length: 26, x: 28, y: 4)
            burstLine(angle: 30, length: 22, x: 46, y: 16)

            // القلب الصغير
            Image(systemName: "heart.fill")
                .font(.system(size: 20))
                .foregroundColor(color)
                .rotationEffect(.degrees(-20))
                .offset(x: -22, y: -26)
        }
    }

    private func burstLine(angle: Double, length: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Capsule()
            .fill(color)
            .frame(width: 5, height: length)
            .rotationEffect(.degrees(angle))
            .offset(x: x, y: y)
    }
}

#Preview {
    Page15()
}
