import Foundation

final class PinService {
    private let defaults = UserDefaults.standard
    private let pinnedTrackerKey = "PinnedTracker"

    // Save the ID of the pinned tracker
    func pinTracker(withId id: UUID) {
        defaults.set(id.uuidString, forKey: pinnedTrackerKey)
        LogService.shared.log("Pinned \(id) tracker", level: .info)
    }

    // Unpin the currently pinned tracker
    func unpinTracker() {
        defaults.removeObject(forKey: pinnedTrackerKey)
        LogService.shared.log("Unpinned tracker", level: .info)
    }

    // Get the ID of the currently pinned tracker
    func getPinnedTrackerId() -> UUID? {
        guard let idString = defaults.string(forKey: pinnedTrackerKey) else { return nil }
        return UUID(uuidString: idString)
    }

    // Check if a tracker is pinned
    func isTrackerPinned(withId id: UUID) -> Bool {
        return getPinnedTrackerId() == id
    }
}
