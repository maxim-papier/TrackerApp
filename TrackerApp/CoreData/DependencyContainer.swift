import CoreData

final class DependencyContainer {

    let trackerStore: TrackerStore
    let сategoryStore: CategoryStore
    let recordStore: RecordStore

    init(context: NSManagedObjectContext) {

        trackerStore = TrackerStore(context: context)
        сategoryStore = CategoryStore(context: context)
        recordStore = RecordStore(context: context)
    }

    var fetchedResultsControllerForCategory: NSFetchedResultsController<CategoryData> {
        return сategoryStore.fetchedResultsControllerForCategory()
    }

    var fetchedResultsControllerForTrackers: NSFetchedResultsController<TrackerData> {
        return trackerStore.fetchedResultsControllerForTracker()
    }
}
