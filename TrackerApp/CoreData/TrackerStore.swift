import UIKit
import CoreData

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

    lazy var fetchedResultsControllerForPinnedTracker: NSFetchedResultsController<TrackerData> = {
        let sortDescriptor = "createdAt"
        let categorySortDescriptor = "category.name"
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: categorySortDescriptor, ascending: true),
            NSSortDescriptor(key: sortDescriptor, ascending: false)
        ]

        request.predicate = NSPredicate(format: "isPinned == YES")

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Error performing fetch from pinned tracker result controller: \(error)")
        }

        return fetchedResultsController
    }()
    
    func createFetchedResultsController() -> NSFetchedResultsController<TrackerData> {
        let sortDescriptor = "createdAt"
        let categorySortDescriptor = "category.name"
        let pinnedSortDescriptor = "isPinned"
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: pinnedSortDescriptor, ascending: false),
            NSSortDescriptor(key: categorySortDescriptor, ascending: true),
            NSSortDescriptor(key: sortDescriptor, ascending: false)
        ]

        request.predicate = NSPredicate(format: "isPinned == NO")

        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "category.name",
            cacheName: nil
        )

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
    
    func updateFetchedResultsController() {
        NSFetchedResultsController<TrackerData>.deleteCache(withName: nil)
        fetchedResultsController = createFetchedResultsController()
        do {
            try fetchedResultsController?.performFetch()
        } catch let error {
            LogService.shared.log("Unable to perform fetch: \(error)", level: .error)
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
            LogService.shared.log("Error deleting tracker: \(error)", level: .error)
        }
    }
    
    func updateTracker(_ tracker: Tracker) {
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        do {
            let coreDataTrackers = try context.fetch(request)
            guard let coreDataTracker = coreDataTrackers.first else { return }
            
            coreDataTracker.title = tracker.title
            coreDataTracker.emoji = tracker.emoji
            coreDataTracker.colorHEX = tracker.color.toHexString()
            
            if let weekDays = tracker.day, !weekDays.isEmpty {
                let weekDaySet = WeekDaySet(weekDays: weekDays)
                let scheduleData = weekDaySet.toString()
                coreDataTracker.schedule = scheduleData
            } else {
                coreDataTracker.schedule = "no_schedule"
            }
            
            try context.save()
        } catch {
            LogService.shared.log("Error updating tracker: \(error)", level: .error)
        }
    }
    
    func pinTracker(by id: UUID) {
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            // Fetch the tracker
            let coreDataTrackers = try context.fetch(request)
            guard let coreDataTracker = coreDataTrackers.first else { return }

            // Set isPinned to true
            coreDataTracker.isPinned = true
            
            // Save the changes
            try context.save()
        } catch {
            assertionFailure("Error pinning tracker: \(error)")
        }
    }

    func unpinTracker(by id: UUID) {
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            // Fetch the tracker
            let coreDataTrackers = try context.fetch(request)
            guard let coreDataTracker = coreDataTrackers.first else { return }

            // Set isPinned to false
            coreDataTracker.isPinned = false
            
            // Save the changes
            try context.save()
        } catch {
            assertionFailure("Error unpinning tracker: \(error)")
        }
    }
    
    func getPinnedTrackersExist() -> Bool {
        let pinnedRequest: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        pinnedRequest.predicate = NSPredicate(format: "isPinned == true")
        pinnedRequest.fetchLimit = 1

        var hasPinnedTrackers = false
        do {
            let count = try context.count(for: pinnedRequest)
            hasPinnedTrackers = (count > 0)
        } catch {
            print("Failed to fetch pinned trackers: \(error)")
        }
        
        return hasPinnedTrackers
    }

    
    // MARK: - Conversion methods
    
    private func coreDataTracker(from tracker: Tracker) -> TrackerData {
        
        let coreDataTracker = TrackerData(context: context)
        
        coreDataTracker.id = tracker.id
        coreDataTracker.title = tracker.title
        coreDataTracker.emoji = tracker.emoji
        coreDataTracker.colorHEX = tracker.color.toHexString()
        coreDataTracker.isPinned = tracker.isPinned
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
        
        let isPinned = coreDataTracker.isPinned
        let color = UIColor(hexString: colorHex)
        
        var schedule = Set<WeekDay>()
        if let scheduleData = coreDataTracker.schedule {
            if let weekDaySet = WeekDaySet.fromString(scheduleData) {
                schedule = weekDaySet.weekDays
            }
        }
        
        return Tracker(
            id: id,
            title: title,
            emoji: emoji,
            color: color,
            day: schedule,
            isPinned: isPinned,
            createdAt: createdAt
        )
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
    
    // Filter by day of the week and all the rest

    enum FilterSetting {
        case all, day, dayDone, dayNotDone
    }

    func updatePredicateForWeekDayFilter(date: Date, filterSetting: FilterSetting = .day) {
        
        let weekDayPredicate = createWeekDayPredicate(for: date) // .day
        let donePredicate = NSPredicate(format: "SUBQUERY(records, $x, $x.doneDate == %@).@count > 0", date as NSDate)  // .dayDone
        let undonePredicate = NSPredicate(format: "SUBQUERY(records, $x, $x.doneDate == %@).@count == 0", date as NSDate)  // .dayNotDone
        let noPinnedPredicate = NSPredicate(format: "isPinned == NO")
        let pinnedPredicate = NSPredicate(format: "isPinned == YES")

        let filterPredicate: NSPredicate

        switch filterSetting {
        case .all:
            filterPredicate = .init()
        case .day:
            filterPredicate = weekDayPredicate
        case .dayDone:
            filterPredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [weekDayPredicate, donePredicate]
            )
        case .dayNotDone:
            filterPredicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [weekDayPredicate, undonePredicate]
            )
        }

        fetchedResultsControllerForPinnedTracker.fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [filterPredicate, pinnedPredicate]
        )

        fetchedResultsController!.fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [filterPredicate, noPinnedPredicate]
        )

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
    
    func getNumberOfTrackersForDay(date: Date) -> Int {

        let weekDayPredicate = createWeekDayPredicate(for: date)
        let request: NSFetchRequest<TrackerData> = TrackerData.fetchRequest()
        request.predicate = weekDayPredicate
        
        do {
            let numberOfTrackers = try context.count(for: request)
            return numberOfTrackers
        } catch {
            assertionFailure("Error fetching trackers count: \(error)")
            return 0
        }
    }

    
    
    // MARK: - Fetching methods
    
    private func performFetch() {
        do {
            try fetchedResultsController?.performFetch()
            try fetchedResultsControllerForPinnedTracker.performFetch()
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


