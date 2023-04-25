import Foundation

class WeekDaySet: NSObject, Codable {
    var weekDays: Set<WeekDay>

    init(weekDays: Set<WeekDay>) {
        self.weekDays = weekDays
    }
}
