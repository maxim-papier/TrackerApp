import Foundation

class WeekDaySet: NSObject, Codable {
    var weekDays: Set<WeekDay>

    init(weekDays: Set<WeekDay>) {
        self.weekDays = weekDays
    }
}

extension WeekDaySet {

    func toString() -> String {
        
        let encoder = JSONEncoder()

        guard
            let encodedData = try? encoder.encode(self),
            let jsonString = String(data: encodedData, encoding: .utf8)
        else {
            LogService.shared.log("Error encoding WeekDaySet", level: .error)
            return .init()
        }
        LogService.shared.log("Encoded WeekDaySet: \(jsonString)", level: .info)
        return jsonString
    }

    static func fromString(_ string: String) -> WeekDaySet? {
        if string == "no_schedule" {
            return WeekDaySet(weekDays: Set())
        }
        
        let decoder = JSONDecoder()
        
        guard let data = string.data(using: .utf8) else {
            LogService.shared.log("Error converting JSON string to data", level: .error)
            return nil
        }

        do {
            let weekDaySet = try decoder.decode(WeekDaySet.self, from: data)
            //LogService.shared.log("Decoded WeekDaySet: \(weekDaySet)", level: .info)
            return weekDaySet
        } catch {
            LogService.shared.log("Error decoding WeekDaySet: \(error)", level: .error)
            return nil
        }
    }
}
