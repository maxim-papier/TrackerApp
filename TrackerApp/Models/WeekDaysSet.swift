import Foundation

final class WeekDaySet: NSObject, NSCoding {

    var weekDays: Set<WeekDay>
    let key = "weekDays"

    init(weekDays: Set<WeekDay>) {
        self.weekDays = weekDays
    }

    required convenience init?(coder decoder: NSCoder) {
        guard let weekDays = decoder.decodeObject(forKey: "weekDays") as? Set<WeekDay> else { return nil }
        self.init(weekDays: weekDays)
    }

    func encode(with coder: NSCoder) {
        coder.encode(weekDays, forKey: key)
    }
}

