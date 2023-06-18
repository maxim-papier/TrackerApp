import UIKit
import CoreData

final class RecordStore: NSObject {

    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Main method
    
    func toggleRecord(forTrackerWithID trackerID: UUID) {
        if let recordID = getRecordID(forTrackerWithID: trackerID) {
            deleteRecord(by: recordID)
        } else {
            addRecord(forTrackerWithID: trackerID)
        }
    }
    
    // MARK: - CRUD methods
    
    private func addRecord(forTrackerWithID trackerID: UUID) {
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)

        do {
            let fetchedTrackers = try context.fetch(request)
            guard let coreDataTracker = fetchedTrackers.first else { return }

            let record = TrackerRecordData(context: context)
            record.id = UUID()
            record.doneDate = Date()
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
    
    func getRecordID(forTrackerWithID trackerID: UUID) -> UUID? {
        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)

        do {
            let fetchedRecords = try context.fetch(request)
            return fetchedRecords.first?.id
        } catch {
            assertionFailure("Error getting tracker record ID: \(error)")
            return nil
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
