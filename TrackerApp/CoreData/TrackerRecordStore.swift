import UIKit
import CoreData

final class TrackerRecordStore: NSObject {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - CRUD methods

    func addRecord(forTrackerWithID trackerID: UUID) {
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)

        do {
            let fetchedTrackers = try context.fetch(request)
            guard let coreDataTracker = fetchedTrackers.first else { return }

            let record = TrackerRecordData(context: context)
            record.id = UUID()
            record.date = Date()
            record.tracker = coreDataTracker

            try context.save()
        } catch {
            print("Error adding tracker record: \(error)")
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

    private func coreDataTracker(from tracker: Tracker) -> TrackerData {

        let coreDataTracker = TrackerData(context: context)
        coreDataTracker.id = tracker.id
        coreDataTracker.title = tracker.title
        coreDataTracker.emoji = tracker.emoji
        coreDataTracker.colorHEX = tracker.color.toHexString()
        coreDataTracker.createdAt = tracker.createdAt

        let weekDaySet = WeekDaySet(weekDays: tracker.day ?? Set())
        let scheduleData = weekDaySet.toData()
        coreDataTracker.schedule = scheduleData

        return coreDataTracker
    }

    private func tracker(from coreDataTracker: TrackerData) -> Tracker? {

        guard
            let id = coreDataTracker.id,
            let title = coreDataTracker.title,
            let emoji = coreDataTracker.emoji,
            let colorHex = coreDataTracker.colorHEX,
            let createdAt = coreDataTracker.createdAt
        else {
            return nil
        }

        let color = UIColor(hexString: colorHex)

        var schedule = Set<WeekDay>()
        if let scheduleData = coreDataTracker.schedule {
            if let weekDaySet = WeekDaySet.fromData(scheduleData) {
                schedule = weekDaySet.weekDays
            }
        }

        return Tracker(id: id, title: title, emoji: emoji, color: color, day: schedule, createdAt: createdAt)
    }

    private func trackerRecord(from coreDataRecord: TrackerRecordData) -> TrackerRecord? {

            guard
                let id = coreDataRecord.id,
                let date = coreDataRecord.date
            else {
                return nil
            }

            return TrackerRecord(id: id, date: date)
        }
}
