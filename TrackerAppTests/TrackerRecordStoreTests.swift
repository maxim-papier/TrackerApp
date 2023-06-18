import CoreData
import XCTest
@testable import TrackerApp

final class TrackerRecordStoreTests: XCTestCase {

    var context: NSManagedObjectContext!
    var recordStore: RecordStore!

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
        recordStore = RecordStore(context: context)
    }

    override func tearDown() {
        recordStore = nil
        super.tearDown()
    }

    func testCreateRecord() {

        let record = Record(id: UUID(), date: Date())

        recordStore.createTrackerRecord(record: record)

        let readRecords = recordStore.readTrackerRecord()
        XCTAssertEqual(readRecords.count, 1)
    }

    func testReadRecord() {

        let record = Record(id: UUID(), date: Date())

        recordStore.createTrackerRecord(record: record)

        let readRecords = recordStore.readTrackerRecord()
        XCTAssertEqual(readRecords.first?.id, record.id)
        XCTAssertEqual(readRecords.first?.date, record.date)
    }

    func testUpdateRecord() {
        let record = Record(id: UUID(), date: Date())
        recordStore.createTrackerRecord(record: record)

        let updatedDate = Date().addingTimeInterval(60 * 60 * 24)
        let updatedRecord = Record(id: record.id, date: updatedDate)
        recordStore.updateTrackerRecord(record: updatedRecord)

        let readRecords = recordStore.readTrackerRecord()
        XCTAssertEqual(readRecords.count, 1)
        XCTAssertEqual(readRecords.first?.id, record.id)
        XCTAssertEqual(readRecords.first?.date, updatedDate)
    }

    func testDeleteRecord() {

        let record = Record(id: UUID(), date: Date())
        recordStore.createTrackerRecord(record: record)

        recordStore.deleteTrackerRecord(by: record.id)

        let readRecords = recordStore.readTrackerRecord()
        XCTAssertEqual(readRecords.count, 0)
    }

}
