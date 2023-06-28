import Foundation
import Combine

final class PinService {
    
    private let stores: DependencyContainer
    
    init(stores: DependencyContainer) {
        self.stores = stores
    }

    // Pin the tracker
    func pinTracker(withId id: UUID) {
        stores.trackerStore.pinTracker(by: id)
        LogService.shared.log("Pinned \(id) tracker", level: .info)
    }

    // Unpin the tracker
    func unpinTracker(withId id: UUID) {
        stores.trackerStore.unpinTracker(by: id)
        LogService.shared.log("Unpinned \(id) tracker", level: .info)
    }

    // Check if a tracker is pinned
    func isTrackerPinned(withId id: UUID) -> Bool {
        // Fetch the tracker
        do {
            let tracker = try stores.trackerStore.readTracker(by: id)
            return tracker.isPinned
        } catch {
            LogService.shared.log("Error reading tracker: \(error)", level: .error)
            return false
        }
    }
}
