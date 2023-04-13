import UIKit
import CoreData

final class TrackerCategoryStore {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - CRUD methods

    func createTrackerCategory(category: TrackerCategory) {

        _ = coreDataTrackerCategory(from: category)

        do {
            try context.save()
        } catch {
            print("Error saving category: \(error)")
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

    func updateTrackerCategory(category: TrackerCategory) -> [TrackerCategory] {

        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "id == $0", category.id as CVarArg)

        do {
            let coreDataCategories = try context.fetch(request)
            guard let coreDataCategory = coreDataCategories.first else { return [] }

            coreDataCategory.name = category.name

            // Update trackers relationship
            let newTrackers = category.trackers.map { coreDataTracker(from: $0) }
            coreDataCategory.trackers = NSSet(array: newTrackers)

            try context.save()
        } catch {
            print("Error updating category: \(error)")
        }

        return readTrackerCategories()
    }

    func deleteTrackerCategory(by id: UUID) {

        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        request.predicate = NSPredicate(format: "id == $0", id as CVarArg)

        do {
            let coreDataCategories = try context.fetch(request)
            guard let coreDataCategory = coreDataCategories.first else { return }
            context.delete(coreDataCategory)
            try context.save()
        } catch {
            print("Error deleting category: \(error)")
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
