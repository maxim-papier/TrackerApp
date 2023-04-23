import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChangeContent()
}

final class TrackerCategoryStore: NSObject {

    weak var delegate: TrackerCategoryStoreDelegate?

    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<CategoryData>?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }


    // MARK: - FetchedResultsController

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

    func createFetchedResultsController() -> NSFetchedResultsController<CategoryData> {

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


    func readTrackerCategories() -> [TrackerCategory] {

        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()

        do {
            let coreDataCategories = try context.fetch(request)
            return coreDataCategories.compactMap { trackerCategory(form: $0) }
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }

    func updateTrackerCategory(category: TrackerCategory) {

        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)

        do {
            let coreDataCategories = try context.fetch(request)
            guard let coreDataCategory = coreDataCategories.first else { return }

            coreDataCategory.name = category.name

            // Update trackers relationship
            let newTrackers = category.trackers.map { coreDataTracker(from: $0) }
            coreDataCategory.trackers = NSSet(array: newTrackers)

            try context.save()
        } catch {
            print("Error updating category: \(error)")
        }
    }

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

    func addTrackerToCategory(tracker: Tracker, categoryId: UUID? = nil) {
        // Если categoryId не предоставлен, создаем новую категорию
        if let categoryId = categoryId {
            if let category = readTrackerCategories().first(where: { $0.id == categoryId }) {
                // Категория найдена, добавляем трекер в существующую категорию
                var updatedTrackers = category.trackers
                updatedTrackers.append(tracker)
                let updatedCategory = TrackerCategory(id: category.id, name: category.name, trackers: updatedTrackers, createdAt: category.createdAt)
                updateTrackerCategory(category: updatedCategory)
            } else {
                print("Category with id \(categoryId) not found")
            }
        } else {
            // Создаем новую категорию с трекером
            let newCategory = TrackerCategory(id: UUID(), name: "New Category", trackers: [tracker], createdAt: Date())
            createTrackerCategory(category: newCategory)
        }
    }

    func getTrackerCategory(by id: UUID) -> TrackerCategory? {
        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let coreDataCategories = try context.fetch(request)
            guard let coreDataCategory = coreDataCategories.first else { return nil }
            return trackerCategory(form: coreDataCategory)
        } catch {
            print("Error fetching category by id: \(error)")
            return nil
        }
    }

    

    // MARK: - Clean all categories data

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

    private func trackerCategory(form coreDataCategory: CategoryData) -> TrackerCategory? {

        guard
            let id = coreDataCategory.id,
            let name = coreDataCategory.name,
            let trackersData = coreDataCategory.trackers as? Set<TrackerData>,
            let createdAt = coreDataCategory.createdAt
        else {
            return nil
        }

        let trackers = trackersData.compactMap { tracker(from: $0) }

        return TrackerCategory(id: id, name: name, trackers: trackers, createdAt: createdAt)

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

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidChangeContent()
    }

}
