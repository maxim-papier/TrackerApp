import Foundation
import CoreData

final class TrackerRecordStore: NSObject {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - CRUD methods

    func createTrackerRecord(record: TrackerRecord) {

        _ = coreDataTrackerRecord(from: record)
        do {
            try context.save()
        } catch {
            print("Error saving tracker record: \(error)")
        }
    }

    func readTrackerRecord() -> [TrackerRecord] {

        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        do {
            let coreDataRecords = try context.fetch(request)
            return coreDataRecords.compactMap( { trackerRecords(from: $0)  } )
        } catch {
            print("Error fetching tracker records: \(error)")
            return []
        }
    }

    func updateTrackerRecord(record: TrackerRecord) {
        let request: NSFetchRequest<TrackerRecordData> = TrackerRecordData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)

        do {
            let coreDataRecords = try context.fetch(request)
            guard let coreDataRecord = coreDataRecords.first else { return }

            coreDataRecord.date = record.date

            try context.save()
        } catch {
            print("Error updating tracker record: \(error)")
        }
    }


    func deleteTrackerRecord(by id: UUID) {

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

    // MARK: - Clean all records data

    func clearRecordData() {

        print("Clearing records data...")

        let request: NSFetchRequest<NSFetchRequestResult> = TrackerRecordData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("Error deleting category data: \(error.localizedDescription)")
        }
    }


    // MARK: - Conversion methods

    private func coreDataTrackerRecord(from record: TrackerRecord) -> TrackerRecordData {

        let coreDataRecord = TrackerRecordData(context: context)
        coreDataRecord.id = record.id
        coreDataRecord.date = record.date

        return coreDataRecord
    }

    private func trackerRecords(from coreDataRecord: TrackerRecordData) -> TrackerRecord? {

        guard
            let id = coreDataRecord.id,
            let date = coreDataRecord.date
        else {
            return nil
        }

        return TrackerRecord(id: id, date: date)
    }

}