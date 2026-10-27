import SwiftUI

struct Scenario: Equatable {
    let title: String
    let text: String
    var colors: [String] = []   // 4 suggested hex colors (empty = use the mood's palette)
}

enum Mood: String, CaseIterable, Identifiable {
    case happy = "Happy", angry = "Angry", sad = "Sad", confused = "Confused"

    var id: String { rawValue }

    var imageName: String {
        switch self {
        case .happy: "happy"
        case .angry: "frustrated"
        case .sad: "sad"
        case .confused: "confused"
        }
    }

    var color: Color {
        switch self {
        case .happy: .starYellow
        case .angry: .softOrange
        case .sad: .softBlue
        case .confused: .softRose
        }
    }

    /// 4 suggested colors for each mood.
    var palette: [String] {
        switch self {
        case .happy: ["FFD84D", "F2913D", "E79A8B", "9DB89A"]
        case .angry: ["D7855A", "C9573F", "8FA9C7", "5B7FA6"]
        case .sad: ["8FA9C7", "B7C8DD", "F2C29F", "FFE59A"]
        case .confused: ["B9A7D6", "E79A8B", "9DB89A", "F1E0C5"]
        }
    }

    static let defaultPalette = ["D7855A", "FFD84D", "9DB89A", "8FA9C7"]

    /// Rule-based drawing ideas for each mood.
    var scenarios: [Scenario] {
        switch self {
        case .happy: [
            Scenario(title: "Your Happy Garden",
                     text: "Draw one flower for every good thing that happened today. Make them big, small, bright, or wild."),
            Scenario(title: "Catch the Moment",
                     text: "Think of the best moment of your day and draw it like a photo you want to keep forever."),
            Scenario(title: "Colors of Joy",
                     text: "Pick the colors that feel like happiness to you. Fill the page with shapes, stars, and swirls in those colors.")
        ]
        case .angry: [
            Scenario(title: "Storm and Calm",
                     text: "Draw a strong storm with fast, heavy lines. Then slowly draw the calm sky that comes after it."),
            Scenario(title: "Shake It Out",
                     text: "Fill the page with scribbles. When you are ready, turn some of them into soft round shapes."),
            Scenario(title: "Cool Down",
                     text: "Draw a fire with strong red lines. Then slowly cover it with calm blue waves until it feels quiet.")
        ]
        case .sad: [
            Scenario(title: "A Safe Place",
                     text: "Imagine a place where you feel safe and warm. Draw it slowly and add the small details."),
            Scenario(title: "The Weather Inside",
                     text: "If your feelings were weather, what would they be? Draw it, then add one small thing that gives you hope."),
            Scenario(title: "A Small Light",
                     text: "Draw a dark night sky. Then add one small light: a star, a candle, or a window. Let it slowly grow brighter.")
        ]
        case .confused: [
            Scenario(title: "A Sky Full of Thoughts",
                     text: "Imagine your mind as a sky filled with thoughts.\n\nDraw a sun that represents YOU. Each ray is a different thought. Make them long, short, straight, or wavy, and write on them if you like."),
            Scenario(title: "Find Your Path",
                     text: "Draw where you are now on one side and where you want to be on the other. Then draw the path between them."),
            Scenario(title: "Untangle the Lines",
                     text: "Draw a messy ball of lines. Then pick one line and follow it slowly until it becomes a clear, simple shape.")
        ]
        }
    }
}

/// Each sound file in the project must use its `fileName` (.mp3, .m4a, or .wav).
enum Sound: String, CaseIterable, Identifiable {
    case sea = "Calm Sea"
    case meadow = "Morning Meadow"
    case piano = "Soft Piano"
    case lofi = "Lo-fi Courtyard"

    var id: String { rawValue }

    var fileName: String {
        switch self {
        case .sea: "sea"
        case .meadow: "morning"
        case .piano: "piano"
        case .lofi: "music"
        }
    }

    /// Short line shown under the sound's name.
    var subtitle: String {
        switch self {
        case .sea: "Slow waves rolling onto the shore"
        case .meadow: "Birds and a soft breeze in the open air"
        case .piano: "Slow, gentle notes to help you breathe"
        case .lofi: "Soft lo-fi beats for calm focus"
        }
    }

    /// Keeps every sound at a similar loudness (0 to 1). Adjust after listening.
    var volume: Float {
        switch self {
        case .sea: 0.5
        case .meadow: 0.5
        case .piano: 0.5
        case .lofi: 0.25
        }
    }
}

enum DrawTool {
    case hand, brush, eraser
}

enum InkType: String, CaseIterable, Identifiable {
    case pen = "Pen", pencil = "Pencil", marker = "Marker", charcoal = "Charcoal",
         watercolor = "Watercolor", calligraphy = "Calligraphy", fineLiner = "Fine liner"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pen: "pencil.tip"
        case .pencil: "pencil"
        case .marker: "highlighter"
        case .charcoal: "scribble.variable"
        case .watercolor: "drop"
        case .calligraphy: "pencil.and.scribble"
        case .fineLiner: "line.diagonal"
        }
    }
}
