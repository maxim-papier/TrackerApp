import UIKit
import CoreData

enum TrackerStoreChangeType {
    case insert
    case delete
    case update
    case move
}

// MARK: - TrackerStoreDelegate

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange(changeType: TrackerStoreChangeType,
                               object: Any,
                               at indexPath: IndexPath?,
                               newIndexPath: IndexPath?)
}

// MARK: - TrackerStore

final class TrackerStore: NSObject {

    weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerData>?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }

    // MARK: - FetchedResultsController

    /// Initialize and return fetchedResultsController
    func fetchedResultsControllerForTracker() -> NSFetchedResultsController<TrackerData> {
        if let fetchedResultsController = fetchedResultsController {
            return fetchedResultsController
        } else {
            setupFetchedResultsController()
            guard let fetchedResultsController = fetchedResultsController else {
                fatalError("Failed to initialize fetchedResultsController")
            }
            return fetchedResultsController
        }
    }

    private func createFetchedResultsController() -> NSFetchedResultsController<TrackerData> {
        let sortDescriptor = "createdAt"
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: sortDescriptor, ascending: false)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }

    func setupFetchedResultsController() {
        fetchedResultsController = createFetchedResultsController()
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error setting up fetched results controller: \(error)")
        }
    }


    // MARK: - CRUD methods for Tracker

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

            let weekDaySet = WeekDaySet(weekDays: tracker.day ?? Set())
            let scheduleData = try JSONEncoder().encode(weekDaySet)
            coreDataTracker.schedule = scheduleData

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
        coreDataTracker.colorHEX = tracker.color.toHexString()
        coreDataTracker.createdAt = tracker.createdAt

        let weekDaySet = WeekDaySet(weekDays: tracker.day ?? Set())
        let scheduleData = weekDaySet.toData()
        coreDataTracker.schedule = scheduleData

        return coreDataTracker
    }

    func tracker(from coreDataTracker: TrackerData) -> Tracker? {
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


    // MARK: - Clean all trackers data

    func clearTrackerData() {

        print("Clearing trackers data...")

        let request: NSFetchRequest<NSFetchRequestResult> = TrackerData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            print("Error deleting category data: \(error.localizedDescription)")
        }
    }

    // MARK: - Filtering methods

    // Filter by text

    func updatePredicateForTextFilter(searchText: String) {
        let textPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        fetchedResultsController!.fetchRequest.predicate = textPredicate
        performFetch()
    }

    // Filter by day of the week

    func updatePredicateForWeekDayFilter(date: Date) {
        let weekDayPredicate = createWeekDayPredicate(for: date)
        fetchedResultsController!.fetchRequest.predicate = weekDayPredicate
        performFetch()
    }

    private func createWeekDayPredicate(for date: Date) -> NSPredicate {

        let selectedWeekDay = Calendar.current.component(.weekday, from: date)
        guard let selectedWeekDayEnum = WeekDay(rawValue: selectedWeekDay) else {
            return NSPredicate(value: false)
        }

        let selectedWeekDayValue = selectedWeekDayEnum.rawValue

        let lhs = NSExpression(forKeyPath: "schedule")
        let rhs = NSExpression(forConstantValue: selectedWeekDayValue)
        let containsSelectedWeekDay = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .contains, options: [])

        return containsSelectedWeekDay
    }

    // Fetch

    private func performFetch() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error performing fetch after updating predicate: \(error)")
        }
    }



}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {

        var changeType: TrackerStoreChangeType

        switch type {
        case .insert:
            changeType = .insert
        case .delete:
            changeType = .delete
        case .update:
            changeType = .update
        case .move:
            changeType = .move
        @unknown default:
            fatalError("Unhandled case in NSFetchedResultsControllerDelegate")
        }

        delegate?.trackerStoreDidChange(changeType: changeType, object: anObject, at: indexPath, newIndexPath: newIndexPath)
    }
}
