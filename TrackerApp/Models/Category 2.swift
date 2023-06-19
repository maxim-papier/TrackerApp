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


// MARK: - MOCKS

extension Category {
    static var mockCategory1: Self {
        .init(name: "Спорт", trackers: [.mockCase1, .mockCase2,.mockCase3])
    }
    static var mockCategory2: Self {
        .init(name: "Дом", trackers: [.mockCase4, .mockCase5])
    }
}

extension Category: Sequence {
    func makeIterator() -> IndexingIterator<[Tracker]> {
        return trackers.makeIterator()
    }
}
