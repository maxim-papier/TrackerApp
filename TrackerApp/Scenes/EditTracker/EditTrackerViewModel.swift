import UIKit
import Combine

final class EditTrackerViewModel {
    
    weak var delegate: EditTrackerDelegate?
    
    private let trackerID: UUID
    private let dependency: DependencyContainer
    private var cancellables = Set<AnyCancellable>()
    private var originalCategory: Category?

    
    @Published var trackerTitle: String = "" { didSet { checkValidity() } }
    @Published var trackerEmoji: String = "" { didSet { checkValidity() } }
    @Published var trackerColor: SelectionColorStyle? { didSet { checkValidity() } }
    @Published var trackerSchedule: Set<WeekDay> = [] { didSet { checkValidity() } }
    @Published var trackerCategory: Category? { didSet { checkValidity() } }
    @Published var isTrackerReady: Bool = false
    
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
                originalCategory = category
            }
            
            LogService.shared.log("Tracker's scheduler == \(trackerSchedule)", level: .info)
            
        } catch TrackerStore.TrackerStoreError.notFound {
            LogService.shared.log("Tracker with \(trackerID) not found", level: .error)
        } catch TrackerStore.TrackerStoreError.coreDataError(let coreDataError) {
            LogService.shared.log("CoreData error — \(coreDataError) — while fetching tracker with \(trackerID)")
        } catch {
            LogService.shared.log("Unknown error while fetching tracker with \(trackerID)", level: .error)
        }
    }
    
    private func checkValidity() {
        print("Checking validity")
        isTrackerReady = trackerTitle != "" &&
        trackerEmoji != "" &&
        trackerColor != nil &&
        !trackerSchedule.isEmpty &&
        trackerCategory != nil
        print("Is tracker ready: \(isTrackerReady)")
    }
    
    func saveTrackerData() {
        
        let updatedTracker = Tracker(
            id: trackerID,
            title: trackerTitle,
            emoji: trackerEmoji,
            color: UIColor.selectionColorYP(trackerColor ?? .selection01) ?? .black,
            day: trackerSchedule
        )
        
        // Update the tracker
        dependency.trackerStore.updateTracker(updatedTracker)
        
        // Update the category of the tracker if it has been changed
        if
            let updatedCategoryId = trackerCategory?.id,
            let originalCategoryId = originalCategory?.id,
            updatedCategoryId != originalCategoryId {
            dependency.сategoryStore.updateCategoryForTracker(
                with: trackerID,
                to: updatedCategoryId
            )
        }
        
        delegate?.didUpdateTracker(tracker: updatedTracker)
    }
}


// MARK: - The UpdateTracker Delegate

protocol EditTrackerDelegate: AnyObject {
    func didUpdateTracker(tracker: Tracker)
}
