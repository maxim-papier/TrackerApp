import XCTest
import CoreData
@testable import TrackerApp

final class TrackerStoreTests: XCTestCase {

    var context: NSManagedObjectContext!
    var trackerStore: TrackerStore!

    override func setUp() {
        super.setUp()

        let container = NSPersistentContainer(name: "TrackerDataModel")

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            precondition(description.type == NSInMemoryStoreType)

            if let error {
                fatalError("Create an in-memory coordinator failed \(error)")
            }
        }

        context = container.viewContext
        trackerStore = TrackerStore(context: context)
    }

    override func tearDown() {
        trackerStore = nil
        super.tearDown()
    }

    func testCreateReadTracker() {

        let tracker = Tracker.mockCase1
        trackerStore.createTracker(tracker: tracker)

        let readTrackers = trackerStore.readTrackers()
        print("TEST TRACKER DATA === \(readTrackers)")
        XCTAssertEqual(readTrackers.count, 1)
        XCTAssertEqual(readTrackers.first?.id, tracker.id)
    }

    func testUpdateTracker() {

        let tracker = Tracker.mockCase2
        trackerStore.createTracker(tracker: tracker)

        let updatedTracker = Tracker(id: tracker.id,
                                     title: "Updated Title",
                                     emoji: "🐇",
                                     color: tracker.color,
                                     day: tracker.day,
                                     createdAt: tracker.createdAt)
        trackerStore.updateTracker(tracker: updatedTracker)

        let readTracker = trackerStore.readTrackers()
        XCTAssertEqual(readTracker.count, 1)
        XCTAssertEqual(readTracker.first?.title, "Updated Title")
        XCTAssertEqual(readTracker.first?.emoji, "🐇")
    }

    func testDeleteTracker() {

        let tracker = Tracker.mockCase3
        trackerStore.createTracker(tracker: tracker)

        trackerStore.deleteTracker(by: tracker.id)

        let readTrackers = trackerStore.readTrackers()
        XCTAssertEqual(readTrackers.count, 0)
    }

}
