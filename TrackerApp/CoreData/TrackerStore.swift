import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreWillUpdate()
    func trackerStoreDidInsert(at indexPath: IndexPath)
    func trackerStoreDidDelete(at indexPath: IndexPath)
    func trackerStoreDidUpdate(at indexPath: IndexPath)
    func trackerStoreDidMove(from oldIndexPath: IndexPath, to newIndexPath: IndexPath)
    func trackerStoreDidUpdate()
}


final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {

    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerData>?
    weak var delegate: TrackerStoreDelegate?

    init(context: NSManagedObjectContext) {
        self.context = context
    }



    // MARK: - Fetch Controller


    func setupFetchedResultsController() {

        let sortDescriptor = "title"

        let fetchRequest: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortDescriptor, ascending: true)]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Unable to perform fetch request: \(error)")
        }

    }


    // MARK: - NSFetchedResultsControllerDelegate

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreWillUpdate()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        #warning("make it safe")
        switch type {
        case .insert:
            delegate?.trackerStoreDidInsert(at: newIndexPath!)
        case .delete:
            delegate?.trackerStoreDidDelete(at: indexPath!)
        case .update:
            delegate?.trackerStoreDidUpdate(at: indexPath!)
        case .move:
            delegate?.trackerStoreDidMove(from: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError("Unknown change type")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }



    // MARK: - CRUD methods

    func createTracker(tracker: Tracker) {
        _ = coreDataTracker(from: tracker)
        do {
            try context.save()
        } catch {
            print("Error saving tracker: \(error)")
        }
    }

    func readTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        do {
            let coreDataTrackers = try context.fetch(request)
            return coreDataTrackers.compactMap { tracker(from: $0) }
        } catch {
            print("Error fetching trackers: \(error)")
            return []
        }
    }

    func updateTracker(tracker: Tracker) {
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)

        do {
            let coreDataTrackers = try context.fetch(request)
            guard let coreDataTracker = coreDataTrackers.first else { return }

            coreDataTracker.colorHEX = tracker.color.toHexString()
            coreDataTracker.emoji = tracker.emoji
            coreDataTracker.title = tracker.title

            if let archivedScheduleData = try? NSKeyedArchiver.archivedData(withRootObject: tracker.day ?? Set(), requiringSecureCoding: false) {
                coreDataTracker.schedule = archivedScheduleData
            }

            try context.save()
        } catch {
            print("Error updating tracker: \(error)")
        }
    }


    func deleteTracker(by id: UUID) {
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let coreDataTrackers = try context.fetch(request)
            guard let coreDataTracker = coreDataTrackers.first else { return }
            context.delete(coreDataTracker)
            try context.save()
        } catch {
            print("Error deleting tracker: \(error)")
        }
    }


    // MARK: - Conversion methods

    private func coreDataTracker(from tracker: Tracker) -> TrackerData {

        let coreDataTracker = TrackerData(context: context)
        coreDataTracker.id = tracker.id
        coreDataTracker.title = tracker.title
        coreDataTracker.emoji = tracker.emoji

        let trackerColorHex = tracker.color.toHexString()
        coreDataTracker.colorHEX = trackerColorHex
        coreDataTracker.createdAt = tracker.createdAt

        let weekDaySet = WeekDaySet(weekDays: tracker.day ?? Set())
        let scheduleData = try? NSKeyedArchiver.archivedData(withRootObject: weekDaySet, requiringSecureCoding: false)
        coreDataTracker.schedule = scheduleData

        return coreDataTracker
    }

    private func tracker(from coreDataTracker: TrackerData) -> Tracker? {
        guard let id = coreDataTracker.id,
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
            do {
                if let weekDaySet = try NSKeyedUnarchiver.unarchivedObject(ofClass: WeekDaySet.self, from: scheduleData) {
                    schedule = weekDaySet.weekDays
                }
            } catch {
                print("Error unarchiving schedule: \(error)")
            }
        }

        return Tracker(id: id, title: title, emoji: emoji, color: color, day: schedule, createdAt: createdAt)
    }
}

