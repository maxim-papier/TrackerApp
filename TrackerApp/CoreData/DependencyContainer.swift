import CoreData

final class DependencyContainer {

    let trackerStore: TrackerStore
    let trackerCategoryStore: TrackerCategoryStore
    let trackerRecordSore: TrackerRecordStore

    init(context: NSManagedObjectContext) {

        trackerStore = TrackerStore(context: context)
        trackerCategoryStore = TrackerCategoryStore(context: context)
        trackerRecordSore = TrackerRecordStore(context: context)
    }
}
