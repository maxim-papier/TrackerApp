import Foundation

final class WeekDaySet: NSObject, NSCoding, NSSecureCoding {
    static var supportsSecureCoding: Bool = true

    var weekDays: Set<WeekDay>

    init(weekDays: Set<WeekDay>) {
        self.weekDays = weekDays
    }

    required convenience init?(coder decoder: NSCoder) {
        guard let rawWeekDays = decoder.decodeObject(of: [NSSet.self], forKey: "weekDays") as? Set<Int> else { return nil }
        let weekDays = Set(rawWeekDays.compactMap { WeekDay(rawValue: $0) })
        self.init(weekDays: weekDays)
    }

    func encode(with coder: NSCoder) {
        let rawWeekDays = Set(weekDays.map { $0.rawValue })
        coder.encode(rawWeekDays, forKey: "weekDays")
    }
}
