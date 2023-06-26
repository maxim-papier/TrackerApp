import UIKit
import Combine

final class EditTrackerViewModel {
    
    private let trackerID: UUID
    private let dependency: DependencyContainer
    private var cancellables = Set<AnyCancellable>()
    
    @Published var trackerTitle: String = "Unknown"
    @Published var trackerEmoji: String = "🤮"
    @Published var trackerColor: SelectionColorStyle = .selection01
    @Published var trackerSchedule: Set<WeekDay> = []
    @Published var trackerCategory: Category?
    
    init(trackerID: UUID, dependency: DependencyContainer, cancellables: Set<AnyCancellable> = Set<AnyCancellable>()) {
        self.trackerID = trackerID
        self.dependency = dependency
        fetchTracker()
    }
    
    private func fetchTracker() {
        do {
            let tracker = try dependency.trackerStore.readTracker(by: trackerID)
            
            trackerTitle = tracker.title
            trackerEmoji = tracker.emoji
            trackerColor = SelectionColorStyle.fromColor(tracker.color) ?? .selection01
            trackerSchedule = tracker.day ?? []
            
            if let category = dependency.сategoryStore.getCategory(forTrackerId: tracker.id) {
                trackerCategory = category
            }
            
        } catch TrackerStore.TrackerStoreError.notFound {
            LogService.shared.log("Tracker with \(trackerID) not found", level: .error)
        } catch TrackerStore.TrackerStoreError.coreDataError(let coreDataError) {
            LogService.shared.log("CoreData error — \(coreDataError) — while fetching tracker with \(trackerID)")
        } catch {
            LogService.shared.log("Unknown error while fetching tracker with \(trackerID)", level: .error)
        }
    }
    
//    func saveTrackerData() {
//        let updatedTracker = Tracker(
//            id: trackerID,
//            title: trackerTitle,
//            emoji: trackerEmoji,
//            color: trackerColor.toColor(),
//            day: trackerSchedule
//        )
//
//        // Сохраняем трекер
//        do {
//            try dependency.сategoryStore.update(tracker: updatedTracker)
//        } catch {
//            LogService.shared.log("Error updating tracker: \(error)", level: .error)
//        }
//    }
}

