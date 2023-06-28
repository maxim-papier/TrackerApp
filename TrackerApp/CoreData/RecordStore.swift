import Foundation
import CoreData

final class RecordStore: NSObject {
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Main method
    
    func toggleRecord(forTrackerWithID trackerID: UUID, onDate date: Date) {
        if let recordID = getRecordIDForToday(forTrackerWithID: trackerID, onDate: date) {
            deleteRecord(by: recordID)
        } else {
            addRecord(forTrackerWithID: trackerID, onDate: date)
        }
    }
    
    // MARK: - CRUD methods
    
    private func addRecord(forTrackerWithID trackerID: UUID, onDate date: Date) {
        
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        
        do {
            let fetchedTrackers = try context.fetch(request)
            guard let coreDataTracker = fetchedTrackers.first else { return }
            
            let record = TrackerRecordData(context: context)
            record.id = UUID()
            record.doneDate = date
            record.tracker = coreDataTracker
            
            try context.save()
            
        } catch {
            assertionFailure("Error adding tracker record: \(error)")
        }
    }
    
    private func deleteRecord(by id: UUID) {
        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let coreDataRecords = try context.fetch(request)
            guard let coreDataRecord = coreDataRecords.first else { return }
            context.delete(coreDataRecord)
            
            try context.save()
            
        } catch {
            assertionFailure("Error deleting tracker record: \(error)")
        }
    }
    
    // MARK: - Fetching methods
    
    func fetchAllRecords() -> [Record] {
        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        
        do {
            let coreDataRecords = try context.fetch(request)
            let output = coreDataRecords.compactMap { self.trackerRecord(from: $0) }
            return output
        } catch {
            assertionFailure("Error fetching all tracker records: \(error)")
            return []
        }
    }
    
    func getRecordIDForToday(forTrackerWithID trackerID: UUID, onDate date: Date) -> UUID? {
        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "tracker.id == %@", trackerID as CVarArg),
            NSPredicate(format: "doneDate >= %@", startOfDay as CVarArg),
            NSPredicate(format: "doneDate < %@", endOfDay! as CVarArg)
        ])
        
        do {
            let fetchedRecords = try context.fetch(request)
            return fetchedRecords.first?.id
        } catch {
            assertionFailure("Error getting tracker record ID for specified date: \(error)")
            return nil
        }
    }
    
    func fetchRecordsCount(forTrackerWithID trackerID: UUID) -> Int {
        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)
        
        do {
            let fetchedRecords = try context.fetch(request)
            return fetchedRecords.count
        } catch {
            assertionFailure("Error fetching tracker record count: \(error)")
            return 0
        }
    }
    
    // MARK: - Statistic methods
    

    func calculateBestStreak() -> Int {

        let allRecords = fetchAllRecords().sorted(by: { $0.date < $1.date })
        var bestStreak = 0
        var currentStreak = 0
        var currentDate = allRecords.first?.date
        
        for record in allRecords {
            if Calendar.current.isDate(record.date, inSameDayAs: currentDate!) {
                continue
            }
            else if Calendar.current.isDate(record.date, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: currentDate!)!) {
                currentStreak += 1
            }

            else {
                currentStreak = 0
            }
            
            currentDate = record.date
            
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
        }
        
        return bestStreak
    }

    func calculatePerfectDays() -> Int {
        let fetchRequest: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        
        do {
            let allTrackers = try context.fetch(fetchRequest)
            let allRecords = fetchAllRecords()
            
            let groupedRecords = Dictionary(grouping: allRecords, by: { Calendar.current.startOfDay(for: $0.date) })
            let perfectDays = groupedRecords.filter { (_, records) in
                records.count >= allTrackers.count
            }
            
            return perfectDays.count
        } catch {
            assertionFailure("Failed to fetch all tracker data: \(error)")
            return 0
        }
    }

    func calculateCompletedTrackers() -> Int {
        let fetchRequest: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        
        do {
            let allCompletedTrackers = try context.fetch(fetchRequest)
            return allCompletedTrackers.count
        } catch {
            assertionFailure("Failed to fetch all completed trackers data: \(error)")
            return 0
        }
    }

    // MARK: - Conversion method
    
    private func trackerRecord(from coreDataRecord: TrackerRecordData) -> Record? {
        guard
            let id = coreDataRecord.id,
            let date = coreDataRecord.doneDate
        else {
            return nil
        }
        
        return Record(id: id, date: date)
    }
}
