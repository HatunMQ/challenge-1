import SwiftUI

extension Color {
    static let appCream   = Color(hex: "F7F0E6")
    static let paper      = Color(hex: "FCF8F4")
    static let deepBrown  = Color(hex: "2D241C")
    static let softBrown  = Color(hex: "6B5A48")
    static let starYellow = Color(hex: "FFD84D")
    static let gold       = Color(hex: "B89458")
    static let softOrange = Color(hex: "D7855A")
    static let softRose   = Color(hex: "E79A8B")
    static let softBlue   = Color(hex: "8FA9C7")

    init(hex: String) {
        let v = Int(hex.replacingOccurrences(of: "#", with: ""), radix: 16) ?? 0
        self.init(red: Double((v >> 16) & 0xFF) / 255,
                  green: Double((v >> 8) & 0xFF) / 255,
                  blue: Double(v & 0xFF) / 255)
    }
}

/// Aura background image from Assets.
struct AuraBackground: View {
    var body: some View {
        // The image sits in an overlay so it can never make the page bigger than the screen
        Color.appCream
            .overlay {
                Image("aura")
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .ignoresSafeArea()
    }
}
