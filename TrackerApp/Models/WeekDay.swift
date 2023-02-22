enum WeekDay: Int, CaseIterable {
    case sunday = 1
    case monday, tuesday, wednesday, thursday, friday, saturday

    var label: String {
        switch self {
        case .sunday:
            return "Воскресенье"
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        }
    }

    var shortLabel: String {
        switch self {
        case .sunday:
            return "Вс"
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        }
    }
}


extension WeekDay {
    static var mock01: Set<WeekDay> = [.monday, .friday, .sunday]
    static var mock02: Set<WeekDay> = [.sunday, .monday, .tuesday, .wednesday, .tuesday, .friday]
    static var mock03: Set<WeekDay> = [.tuesday, .thursday]
}
