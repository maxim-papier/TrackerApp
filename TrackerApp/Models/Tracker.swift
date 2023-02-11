import UIKit

struct Tracker {
    let id = UUID()
    let title: String
    let emoji: String
    let color: UIColor
    let day: WeekDay
}

extension Tracker {
    static var mockCase: Self {
        Tracker.init(
            title: "Don't skip the leg's day",
            emoji: "🏋️",
            color: .colorYP(.selection18)!,
            day: WeekDay.sunday)
    }
}
