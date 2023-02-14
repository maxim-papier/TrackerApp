enum WeekDay: Int, CaseIterable {
    case sunday = 1
    case monday, tuesday, wednesday, thursday, friday, saturday
}

let dayLabels = ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]
let shortDayLabels = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]

extension WeekDay {
    var label: String {
        return dayLabels[self.rawValue - 1]
    }

    var shortLabel: String {
        return shortDayLabels[self.rawValue - 1]
    }
}

extension WeekDay {
    static var mock01: Set<WeekDay> = [.monday, .friday, .sunday]
    static var mock02: Set<WeekDay> = [.sunday, .monday, .tuesday, .wednesday, .tuesday, .friday]
    static var mock03: Set<WeekDay> = [.tuesday, .thursday]
}
