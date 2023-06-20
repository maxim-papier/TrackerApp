import Foundation

struct Category {

    let name: String
    let trackers: [Tracker]
    let createdAt: Date
    let id: UUID

    init(id: UUID = UUID(), name: String, trackers: [Tracker], createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.trackers = trackers
        self.createdAt = createdAt
    }
}
