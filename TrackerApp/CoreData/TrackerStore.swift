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
    func trackerStoreDidChangeContent()
}

// MARK: - TrackerStore

final class TrackerStore: NSObject {

    weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerData>?
    
    enum TrackerStoreError: Error {
        case notFound
        case coreDataError(Error)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }

    // MARK: - FetchedResultsController

    // Initialize and return fetchedResultsController
    func fetchedResultsControllerForTracker() -> NSFetchedResultsController<TrackerData> {
        if let fetchedResultsController = fetchedResultsController {
            return fetchedResultsController
        } else {
            setupFetchedResultsController()
            guard let fetchedResultsController = fetchedResultsController else {
                assertionFailure("Failed to initialize fetchedResultsController")
                return .init()
            }
            return fetchedResultsController
        }
    }

    private func createFetchedResultsController() -> NSFetchedResultsController<TrackerData> {
        let sortDescriptor = "createdAt"
        let categorySortDescriptor = "category.name"
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: categorySortDescriptor, ascending: true),
            NSSortDescriptor(key: sortDescriptor, ascending: false)
        ]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "category.name", cacheName: nil)
        return fetchedResultsController
    }

    func setupFetchedResultsController() {
        fetchedResultsController = createFetchedResultsController()
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            assertionFailure("Error setting up fetched results controller: \(error)")
        }
    }


    // MARK: - CRUD methods for Tracker

    func createTracker(tracker: Tracker) {
        _ = coreDataTracker(from: tracker)
        do {
            try context.save()
        } catch {
            assertionFailure("Error saving tracker: \(error)")
        }
    }

    func readTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        do {
            let coreDataTrackers = try context.fetch(request)
            return coreDataTrackers.compactMap { tracker(from: $0) }
        } catch {
            assertionFailure("Error fetching trackers: \(error)")
            return []
        }
    }
    
    func readTracker(by id: UUID) throws -> Tracker {
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let coreDataTrackers = try context.fetch(request)
            guard let coreDataTracker = coreDataTrackers.first else { throw TrackerStoreError.notFound }
            guard let tracker = tracker(from: coreDataTracker) else { throw TrackerStoreError.notFound }
            return tracker
        } catch {
            throw TrackerStoreError.coreDataError(error)
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
            assertionFailure("Error deleting tracker: \(error)")
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

        if let weekDays = tracker.day, !weekDays.isEmpty {
            let weekDaySet = WeekDaySet(weekDays: weekDays)
            let scheduleData = weekDaySet.toString()
            coreDataTracker.schedule = scheduleData
        } else {
            coreDataTracker.schedule = "no_schedule"
        }

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
            if let weekDaySet = WeekDaySet.fromString(scheduleData) {
                schedule = weekDaySet.weekDays
            }
        }

        return Tracker(id: id, title: title, emoji: emoji, color: color, day: schedule, createdAt: createdAt)
    }



    // MARK: - Filtering methods

    // Filter by text

    func updatePredicateForTextFilter(searchText: String) {
        if searchText.isEmpty {
            fetchedResultsController!.fetchRequest.predicate = nil
        } else {
            let textPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            fetchedResultsController!.fetchRequest.predicate = textPredicate
        }
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
        let searchString = "\"weekDays\":"
        
        let containsSelectedWeekDay = NSPredicate(format: "schedule CONTAINS %@ AND schedule CONTAINS[cd] %@", searchString, String(selectedWeekDayValue))

        let noSchedulePredicate = NSPredicate(format: "schedule == %@", "no_schedule")
        
        return NSCompoundPredicate(orPredicateWithSubpredicates: [containsSelectedWeekDay, noSchedulePredicate])
    }

    
    // MARK: - Fetching methods

    private func performFetch() {
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            assertionFailure("Error performing fetch after updating predicate: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {  }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidChangeContent()
    }
}


