import Foundation

final class StatisticsViewModel {
    
    private let stores: DependencyContainer
    
    var completedTrackersAmount: Int {
        stores.recordStore.calculateCompletedTrackers()
    }
    
    init(stores: DependencyContainer) {
        self.stores = stores
    }
    
    func numberOfPerfectDays() -> Int {
        let allDays = allDaysWithRecords()
        var perfectDays = 0
        
        for day in allDays {
            let recordCount = recordsCount(for: day)
            let trackersForDay = stores.trackerStore.getNumberOfTrackersForDay(date: day)
            
            if recordCount == trackersForDay {
                perfectDays += 1
            }
        }
        
        return perfectDays
    }
    
    func averageCompletedTrackers() -> Double {
        let allRecords = stores.recordStore.fetchAllRecords()
        
        let groupedRecords = Dictionary(grouping: allRecords, by: { Calendar.current.startOfDay(for: $0.date) })
        let totalDays = groupedRecords.count
        let totalCompletedTrackers = allRecords.count
        
        guard totalDays > 0 else {
            return 0.0
        }
        
        return Double(totalCompletedTrackers) / Double(totalDays)
    }
    
    func calculateLongestPerfectDayStreak() -> Int {
        let allDays = allDaysWithRecords().sorted()
        
        let calendar = Calendar.current
        var allCalendarDays: [Date] = []
        if let startDate = allDays.first,
           let endDate = allDays.last {
            for i in 0...calendar.dateComponents([.day], from: startDate, to: endDate).day! {
                if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                    allCalendarDays.append(date)
                }
            }
        }

        var bestStreak = 0
        var currentStreak = 0

        for day in allCalendarDays {
            let recordCount = recordsCount(for: day)
            let trackersForDay = stores.trackerStore.getNumberOfTrackersForDay(date: day)

            if recordCount == trackersForDay, trackersForDay > 0 {
                currentStreak += 1
                if currentStreak > bestStreak {
                    bestStreak = currentStreak
                }
            } else {
                currentStreak = 0
            }
        }

        return bestStreak
    }

    func totalCompletedTrackers() -> Int {
        let allCompletedTrackersCount = stores.recordStore.calculateCompletedTrackers()
        return allCompletedTrackersCount
    }
    
    private func allDaysWithRecords() -> [Date] {
        let allRecords = stores.recordStore.fetchAllRecords()
        let allDates = allRecords.map { $0.date }
        
        let uniqueDates = Array(Set(allDates.map { Calendar.current.startOfDay(for: $0) }))
        return uniqueDates
    }
    
    private func recordsCount(for date: Date) -> Int {
        let allRecords = stores.recordStore.fetchAllRecords()
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        let recordsForDate = allRecords.filter { record in
            let recordDate = Calendar.current.startOfDay(for: record.date)
            return recordDate >= startOfDay && recordDate < endOfDay
        }
        
        return recordsForDate.count
    }
}
