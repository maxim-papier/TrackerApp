import UIKit
import CoreData

final class TrackerRecordStore: NSObject {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - CRUD methods

    func addOrUpdateRecord(forTrackerWithID trackerID: UUID) {
        
        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)
    

        do {
            let fetchedRecords = try context.fetch(request)

            if let coreDataRecord = fetchedRecords.first {
                coreDataRecord.doneDate = Date()
            } else {
                let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)

                let fetchedTrackers = try context.fetch(request)
                guard let coreDataTracker = fetchedTrackers.first else { return }

                let record = TrackerRecordData(context: context)
                record.doneDate = Date()
                record.tracker = coreDataTracker
            }

            try context.save()
            
        } catch {
            print("Error adding or updating tracker record: \(error)")
        }
    }
    
    func recordExists(forTrackerWithID trackerID: UUID) -> Bool {
        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)

        do {
            let fetchedRecords = try context.fetch(request)
            return !fetchedRecords.isEmpty
        } catch {
            print("Error checking if tracker record exists: \(error)")
            return false
        }
    }



    func deleteRecord(by id: UUID) {

        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let coreDataRecords = try context.fetch(request)
            guard let coreDataRecord = coreDataRecords.first else { return }
            context.delete(coreDataRecord)
            try context.save()
        } catch {
            print("Error deleting tracker record: \(error)")
        }
    }

    func fetchAllRecords() -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()

        do {
            let coreDataRecords = try context.fetch(request)
            return coreDataRecords.compactMap { self.trackerRecord(from: $0) }
        } catch {
            print("Error fetching all tracker records: \(error)")
            return []
        }
    }


    //MARK: - Clear all records

    func clearRecordData() {

        print("Clearing records data...")

        let request: NSFetchRequest<NSFetchRequestResult> = TrackerRecordData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("Error deleting record data: \(error.localizedDescription)")
        }
    }

    // MARK: - Conversion methods

    private func trackerRecord(from coreDataRecord: TrackerRecordData) -> TrackerRecord? {

            guard
                let date = coreDataRecord.doneDate
            else {
                return nil
            }

            return TrackerRecord(date: date)
        }
}
