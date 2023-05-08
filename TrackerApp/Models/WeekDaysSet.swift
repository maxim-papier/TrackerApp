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
            fatalError("Error encoding WeekDaySet")
        }

        print("Encoded WeekDaySet: \(jsonString)")
        return jsonString
    }

    static func fromString(_ string: String) -> WeekDaySet? {
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {
            print("Error converting JSON string to data")
            return nil
        }

        do {
            let weekDaySet = try decoder.decode(WeekDaySet.self, from: data)
            print("Decoded WeekDaySet: \(weekDaySet)")
            return weekDaySet
        } catch {
            print("Error decoding WeekDaySet: \(error)")
            return nil
        }
    }
}
