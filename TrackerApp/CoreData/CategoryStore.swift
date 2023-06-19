import UIKit
import CoreData

protocol CategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidInsertCategory(at indexPath: IndexPath)
    func trackerCategoryStoreDidDeleteCategory(at indexPath: IndexPath)
}

// MARK: - TrackerCategoryStore

final class CategoryStore: NSObject {

    weak var delegate: CategoryStoreDelegate?
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<CategoryData>?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }

    // MARK: - FetchedResultsController

    // Initialize and return fetchedResultsController
    func retrieveFetchedResultsController() -> NSFetchedResultsController<CategoryData> {
        if let fetchedResultsController = fetchedResultsController {
            return fetchedResultsController
        } else {
            setupFetchedResultsController()
            guard let fetchedResultsController = fetchedResultsController else {
                LogService.shared.log("Failed to initialize fetchedResultsController", level: .error)
                return .init()
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
            LogService.shared.log("Error setting up fetched results controller: \(error)", level: .error)
        }
    }
    
    func getCategory(at indexPath: IndexPath) -> Category? {
        guard let fetchedResultsController = fetchedResultsController else {
            LogService.shared.log("FetchedResultsController is not initialized.", level: .error)
            return nil
        }

        let categoryData = fetchedResultsController.object(at: indexPath)
        return trackerCategory(from: categoryData)
    }

    // MARK: - CRUD methods

    // Create a new TrackerCategory in the store
    func create(category: Category) -> Bool {
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
            LogService.shared.log("Error checking or creating category: \(error)", level: .error)
            return false
        }
    }

    // Read all TrackerCategories from the store
    func retrieveAllCategories() -> [Category] {
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()

        do {
            let coreDataCategories = try context.fetch(request)
            return coreDataCategories.compactMap { trackerCategory(from: $0) }
        } catch {
            LogService.shared.log("Error fetching categories: \(error)", level: .error)
            return []
        }
    }

    // MARK: - Adding new tracker into category

    // Add a tracker to an existing category or create a new category if categoryId is not provided
    func add(tracker: Tracker, toCategoryWithId categoryId: UUID? = nil) {
        
        guard let categoryId = categoryId else {
            createNewCategory(with: tracker)
            return
        }

        addToExistingCategory(tracker: tracker, categoryId: categoryId)
    }

    private func createNewCategory(with tracker: Tracker) {
        let newCategory = Category(id: UUID(), name: "New Category", trackers: [tracker], createdAt: Date())
        _ = create(category: newCategory)
    }

    private func addToExistingCategory(tracker: Tracker, categoryId: UUID) {
        
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", categoryId as NSUUID)

        do {
            let coreDataCategories = try context.fetch(request)
            guard let coreDataCategory = coreDataCategories.first else {
                LogService.shared.log("Category with id \(categoryId) not found", level: .error)
                return
            }
            
            let newTrackerData = coreDataTracker(from: tracker)
            coreDataCategory.addToTrackers(newTrackerData)
        
            try context.save()
            
        } catch {
            LogService.shared.log("Error updating category: \(error)", level: .error)
        }
    }
    
    // MARK: - Conversion methods

    private func coreDataTrackerCategory(from category: Category) -> CategoryData {

        let coreDataCategory = CategoryData(context: context)
        coreDataCategory.id = category.id
        coreDataCategory.name = category.name
        coreDataCategory.createdAt = category.createdAt

        let coreDataTrackers = category.trackers.map { coreDataTracker(from: $0) }
        coreDataCategory.trackers = NSSet(array: coreDataTrackers)

        return coreDataCategory
    }

    func trackerCategory(from coreDataCategory: CategoryData) -> Category? {
        guard
            let id = coreDataCategory.id,
            let name = coreDataCategory.name,
            let createdAt = coreDataCategory.createdAt,
            let coreDataTrackers = coreDataCategory.trackers
        else {
            return nil
        }
        let trackers = coreDataTrackers.compactMap { $0 as? TrackerData }.compactMap { tracker(from: $0) }

        return Category(id: id, name: name, trackers: trackers, createdAt: createdAt)
    }

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
            if let weekDaySet = WeekDaySet.fromString(scheduleData) {
                schedule = weekDaySet.weekDays
            }
        }
        return Tracker(id: id, title: title, emoji: emoji, color: color, day: schedule, createdAt: createdAt)
    }
}

// MARK: - FetchedResults Delegate

extension CategoryStore: NSFetchedResultsControllerDelegate {

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
