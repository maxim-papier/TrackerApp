import CoreData

final class DependencyContainer {

    let trackerStore: TrackerStore
    let trackerCategoryStore: TrackerCategoryStore
    let trackerRecordStore: TrackerRecordStore

    init(context: NSManagedObjectContext) {

        trackerStore = TrackerStore(context: context)
        trackerCategoryStore = TrackerCategoryStore(context: context)
        trackerRecordStore = TrackerRecordStore(context: context)
    }

    var fetchedResultsControllerForCategory: NSFetchedResultsController<CategoryData> {
        return trackerCategoryStore.fetchedResultsControllerForCategory()
    }

    var fetchedResultsControllerForTrackers: NSFetchedResultsController<TrackerData> {
        return trackerStore.fetchedResultsControllerForTracker()
    }
}
