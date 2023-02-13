import UIKit

struct Tracker {
    let id = UUID()
    let title: String
    let emoji: String
    let color: UIColor
    let day: Set<WeekDay>?
}

extension Tracker {

    static var mockCase1: Self {
        Tracker.init(
            title: "Don't skip the leg's day",
            emoji: "🏋️",
            color: .colorYP(.selection18)!,
            day: WeekDay.mock01)
    }

    static var mockCase2: Self {
        Tracker.init(
            title: "Kiss your wife",
            emoji: "😘",
            color: .colorYP(.selection18)!,
            day: WeekDay.mock02)
    }

    static var mockCase3: Self {
        Tracker.init(
            title: "Hug your kids",
            emoji: "🤗",
            color: .colorYP(.selection18)!,
            day: WeekDay.mock01)
    }

    static var mockCase4: Self {
        Tracker.init(
            title: "Tidy up",
            emoji: "🧹",
            color: .colorYP(.selection17)!,
            day: WeekDay.mock02)
    }

    static var mockCase5: Self {
        Tracker.init(
            title: "Plumb the kitchen sink",
            emoji: "🪠",
            color: .colorYP(.selection17)!,
            day: WeekDay.mock03)
    }

}
