import Foundation

class WeekDaySet: NSObject, Codable {
    var weekDays: Set<WeekDay>

    init(weekDays: Set<WeekDay>) {
        self.weekDays = weekDays
    }

    func toData() -> Data {
        let encoder = JSONEncoder()
        guard let encodedData = try? encoder.encode(self) else {
            fatalError("Error encoding WeekDaySet")
        }
        return encodedData
    }

    static func fromData(_ data: Data) -> WeekDaySet? {
        let decoder = JSONDecoder()
        do {
            let weekDaySet = try decoder.decode(WeekDaySet.self, from: data)
            return weekDaySet
        } catch {
            print("Error decoding WeekDaySet: \(error)")
            return nil
        }
    }

}


