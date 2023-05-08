import UIKit

struct Tracker {
    var id = UUID()
    let title: String
    let emoji: String
    let color: UIColor
    let day: Set<WeekDay>?
    var createdAt = Date()

    init(id: UUID = UUID(), title: String, emoji: String, color: UIColor, day: Set<WeekDay>?, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.color = color
        self.day = day
        self.createdAt = createdAt
    }
}


// MARK: - Mocks

extension Tracker {

    static var mockCase1: Self {
        Tracker.init(
            title: "Don't skip the leg's day",
            emoji: "🏋️",
            color: .selectionColorYP(.selection18)!,
            day: WeekDay.mock01)
    }

    static var mockCase2: Self {
        Tracker.init(
            title: "Kiss your wife",
            emoji: "😘",
            color: .selectionColorYP(.selection18)!,
            day: WeekDay.mock02)
    }

    static var mockCase3: Self {
        Tracker.init(
            title: "Hug your kids",
            emoji: "🤗",
            color: .selectionColorYP(.selection18)!,
            day: WeekDay.mock01)
    }

    static var mockCase4: Self {
        Tracker.init(
            title: "Tidy up",
            emoji: "🧹",
            color: .selectionColorYP(.selection17)!,
            day: WeekDay.mock02)
    }

    static var mockCase5: Self {
        Tracker.init(
            title: "Plumb the kitchen sink",
            emoji: "🪠",
            color: .selectionColorYP(.selection17)!,
            day: WeekDay.mock03)
    }
}
