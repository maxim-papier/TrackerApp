import Foundation

struct TrackerCategory {

    let name: String
    let trackers: [Tracker]

    init(name: String, trackers: [Tracker]) {
        self.name = name
        self.trackers = trackers
    }
}


extension TrackerCategory {
    static var mockCategory1: Self {
        .init(name: "Спорт", trackers: [.mockCase1, .mockCase2,.mockCase3])
    }
    static var mockCategory2: Self {
        .init(name: "Дом", trackers: [.mockCase4, .mockCase5])
    }
}

extension TrackerCategory: Sequence {
    func makeIterator() -> IndexingIterator<[Tracker]> {
        return trackers.makeIterator()
    }
}

extension TrackerCategory {
    var startIndex: Int {
        return trackers.startIndex
    }

    var endIndex: Int {
        return trackers.endIndex
    }

    subscript(index: Int) -> Tracker {
        return trackers[index]
    }
}

