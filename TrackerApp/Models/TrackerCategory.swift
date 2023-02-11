import Foundation

struct TrackerCategory {

    let title: String
    let trackers: [Tracker]

    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}


extension TrackerCategory {
    static var mockHome: Self {
        .init(title: "Sport", trackers: [.mockCase])
    }
}
