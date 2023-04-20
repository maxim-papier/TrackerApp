import CoreData
import XCTest
@testable import TrackerApp

final class CategoryStoreTests: XCTestCase {

    var context: NSManagedObjectContext!
    var categoryStore: TrackerCategoryStore!
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
        categoryStore = TrackerCategoryStore(context: context)
    }

    override func tearDown() {
        categoryStore = nil
        super.tearDown()
    }

    func testCreateReadCategory() {

        let category = TrackerCategory.mockCategory1
        categoryStore.createTrackerCategory(category: category)

        let readCategories = categoryStore.readTrackerCategories()
        XCTAssertEqual(readCategories.count, 1)
        XCTAssertEqual(readCategories.first?.id, category.id)
    }

    func testUpdateCategory() {

        let category = TrackerCategory.mockCategory1
        categoryStore.createTrackerCategory(category: category)

        let updatedCategory = TrackerCategory(id: category.id,
                                              name: "Updated Category",
                                              trackers: category.trackers,
                                              createdAt: category.createdAt)
        categoryStore.updateTrackerCategory(category: updatedCategory)

        let readCategories = categoryStore.readTrackerCategories()
        XCTAssertEqual(readCategories.count, 1)
        XCTAssertEqual(readCategories.first?.name, "Updated Category")
    }

    func testDeleteCategory() {

        let category = TrackerCategory.mockCategory1
        categoryStore.createTrackerCategory(category: category)

        categoryStore.deleteTrackerCategory(by: category.id)

        let readCategories = categoryStore.readTrackerCategories()
        XCTAssertEqual(readCategories.count, 0)
    }




}


