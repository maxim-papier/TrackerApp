import UIKit
import CoreData

// MARK: - TrackerCategoryStoreDelegate

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidInsertCategory(at indexPath: IndexPath)
    func trackerCategoryStoreDidDeleteCategory(at indexPath: IndexPath)
}

// MARK: - TrackerCategoryStore

final class TrackerCategoryStore: NSObject {

    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<CategoryData>?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }

    // MARK: - FetchedResultsController

    /// Initialize and return fetchedResultsController
    func fetchedResultsControllerForCategory() -> NSFetchedResultsController<CategoryData> {
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

    private func createFetchedResultsController() -> NSFetchedResultsController<CategoryData> {
        let sortDescriptor = "createdAt"
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
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

    // MARK: - CRUD methods

    /// Create a new TrackerCategory in the store
    func createTrackerCategory(category: TrackerCategory) -> Bool {
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", category.name)

        do {
            let results = try context.fetch(request)
            if let _ = results.first {
                return false
            } else {
                _ = coreDataTrackerCategory(from: category)
                try context.save()
                return true
            }
        } catch {
            print("Error checking or creating category: \(error)")
            return false
        }
    }

    /// Read all TrackerCategories from the store
    func readTrackerCategories() -> [TrackerCategory] {
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()

        do {
            let coreDataCategories = try context.fetch(request)
            return coreDataCategories.compactMap { trackerCategory(from: $0) }
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }

    /// Update an existing TrackerCategory in the store
    func updateTrackerCategory(category: TrackerCategory) {
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)

        do {
            let coreDataCategories = try context.fetch(request)
            guard let coreDataCategory = coreDataCategories.first else { return }

            coreDataCategory.name = category.name

            try context.save()
        } catch {
            print("Error updating category: \(error)")
        }
    }

    /// Delete a TrackerCategory by id from the store
    func deleteTrackerCategory(by id: UUID) {
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let coreDataCategories = try context.fetch(request)
            guard let coreDataCategory = coreDataCategories.first else { return }
            context.delete(coreDataCategory)
            try context.save()
        } catch {
            print("Error deleting category: \(error)")
        }
    }

    // MARK: - Adding new tracker into category

    /// Add a tracker to an existing category or create a new category if categoryId is not provided
    func addTrackerToCategory(tracker: Tracker, categoryId: UUID? = nil) {
        guard let categoryId = categoryId else {
            createNewCategory(with: tracker)
            return
        }

        addToExistingCategory(tracker: tracker, categoryId: categoryId)
    }

    private func createNewCategory(with tracker: Tracker) {
        let newCategory = TrackerCategory(id: UUID(), name: "New Category", trackers: [tracker], createdAt: Date())
        _ = createTrackerCategory(category: newCategory)
    }

    private func addToExistingCategory(tracker: Tracker, categoryId: UUID) {
        
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", categoryId as NSUUID)

        do {
            let coreDataCategories = try context.fetch(request)
            guard let coreDataCategory = coreDataCategories.first else {
                print("Category with id \(categoryId) not found")
                return
            }
            
            let newTrackerData = coreDataTracker(from: tracker)
            coreDataCategory.addToTrackers(newTrackerData)
            
            try context.save()
            
        } catch {
            print("Error updating category: \(error)")
        }
        
    }

    /// Get a TrackerCategory by id from the store
    func getTrackerCategory(by id: UUID) -> TrackerCategory? {
        
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let coreDataCategories = try context.fetch(request)
            guard let coreDataCategory = coreDataCategories.first else { return nil }
            return trackerCategory(from: coreDataCategory)
        } catch {
            print("Error fetching category by id: \(error)")
            return nil
        }
    }

    // MARK: - Clean all categories data

    /// Clear all category data from the store
    func clearCategoryData() {
        print("Clearing category data...")

        let request: NSFetchRequest<NSFetchRequestResult> = CategoryData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error deleting category data: \(error)")
        }
    }

    // MARK: - Conversion methods

    private func coreDataTrackerCategory(from category: TrackerCategory) -> CategoryData {

        let coreDataCategory = CategoryData(context: context)
        coreDataCategory.id = category.id
        coreDataCategory.name = category.name
        coreDataCategory.createdAt = category.createdAt

        let coreDataTrackers = category.trackers.map { coreDataTracker(from: $0) }
        coreDataCategory.trackers = NSSet(array: coreDataTrackers)

        return coreDataCategory
    }

    func trackerCategory(from coreDataCategory: CategoryData) -> TrackerCategory? {
        guard
            let id = coreDataCategory.id,
            let name = coreDataCategory.name,
            let createdAt = coreDataCategory.createdAt,
            let coreDataTrackers = coreDataCategory.trackers
        else {
            return nil
        }

        let trackers = coreDataTrackers.compactMap { $0 as? TrackerData }.compactMap { tracker(from: $0) }

        return TrackerCategory(id: id, name: name, trackers: trackers, createdAt: createdAt)
    }

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

}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                delegate?.trackerCategoryStoreDidInsertCategory(at: newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                delegate?.trackerCategoryStoreDidDeleteCategory(at: indexPath)
            }
        default:
            break
        }

    }

}
