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
            return coreDataRecords.compactMap { self.trackerRecord(from: $0) }
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
