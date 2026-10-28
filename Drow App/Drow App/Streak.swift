import SwiftUI

/// The days the user saved a drawing, kept on their own (not inside the drawings),
/// so deleting a drawing does not change the streak.
/// The days are stored as one text of start-of-day times separated by commas,
/// which lets the Home page watch it with @AppStorage.
enum StreakStore {
    static let key = "drawingDays"

    static func days(from raw: String) -> [Date] {
        raw.split(separator: ",")
            .compactMap { Double($0) }
            .map { Date(timeIntervalSince1970: $0) }
    }

    /// The stored text with these dates added (a day is only kept once).
    static func adding(_ dates: [Date], to raw: String, calendar: Calendar = .current) -> String {
        var set = Set(days(from: raw).map { calendar.startOfDay(for: $0) })
        for date in dates { set.insert(calendar.startOfDay(for: date)) }
        return set.sorted().map { String($0.timeIntervalSince1970) }.joined(separator: ",")
    }

    /// Remembers that the user saved a drawing on this day.
    static func record(_ date: Date = .now) {
        let raw = UserDefaults.standard.string(forKey: key) ?? ""
        UserDefaults.standard.set(adding([date], to: raw), forKey: key)
    }
}

/// The streak shown on Home: how many days in a row the user saved a drawing.
enum Streak {
    /// The most days that may pass between two drawing days without breaking the streak.
    /// 2 means one missed day in between is forgiven (the "grace day").
    private static let maxDayGap = 2

    /// The streak ending today (or the last day the user drew, if the grace day still covers it).
    static func current(dates: [Date], today: Date = .now, calendar: Calendar = .current) -> Int {
        // One entry per day, newest first: two drawings on the same day count once
        let days = Set(dates.map { calendar.startOfDay(for: $0) }).sorted(by: >)
        guard let latest = days.first else { return 0 }

        // Too long since the last drawing: the streak is over
        guard dayGap(from: latest, to: calendar.startOfDay(for: today), calendar: calendar) <= maxDayGap else {
            return 0
        }

        var count = 1
        var newer = latest
        for older in days.dropFirst() {
            guard dayGap(from: older, to: newer, calendar: calendar) <= maxDayGap else { break }
            count += 1
            newer = older
        }
        return count
    }

    /// The flame gets darker as the streak grows, reaching its darkest at 30 days.
    static func flameColor(for streak: Int) -> Color {
        // No streak yet: a quiet, faded flame
        guard streak > 0 else { return Color(red: 0.62, green: 0.50, blue: 0.24).opacity(0.5) }

        let t = Double(min(streak, 30)) / 30
        let light = (r: 1.00, g: 0.80, b: 0.35)   // golden yellow
        let dark = (r: 0.55, g: 0.15, b: 0.05)    // deep red-brown
        return Color(
            red: light.r + (dark.r - light.r) * t,
            green: light.g + (dark.g - light.g) * t,
            blue: light.b + (dark.b - light.b) * t
        )
    }

    private static func dayGap(from start: Date, to end: Date, calendar: Calendar) -> Int {
        calendar.dateComponents([.day], from: start, to: end).day ?? Int.max
    }
}
