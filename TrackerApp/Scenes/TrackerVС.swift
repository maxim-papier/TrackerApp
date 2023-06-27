import UIKit
import Combine

enum FilterType {
    case search
    case date
}

final class TrackersVC: UIViewController {
    
    private let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchText = ""
    private var selectedDate = Date()
    private lazy var placeholder = PlaceholderType.noSearchResults.placeholder
    
    weak var trackerStoreDelegate: TrackerStoreDelegate?
    weak var editTrackerDelegate: EditTrackerDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    private var stores: DependencyContainer
    private lazy var fetchedResultsController = {
        stores.fetchedResultsControllerForTrackers
    }()
    
    private let analytic: YandexMetricaService
    private let localization = LocalizationService()
    private let pinService: PinService
    
    
    // MARK: - Init
    
    init(dependencies: DependencyContainer,
         analytic: YandexMetricaService,
         pinSevice: PinService) {
        self.stores = dependencies
        self.analytic = analytic
        self.pinService = pinSevice
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stores.trackerStore.setupFetchedResultsController()
        stores.trackerStore.delegate = self
        filterResults(with: Date())
        setup()
        bindPinningEvent()
        analytic.log(event: .open(screen: .main))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analytic.log(event: .close(screen: .main))
    }
    
    
    // MARK: - Bindings
    
    private func bindPinningEvent() {
        pinService.isPinnedChanged
            .sink { [weak self] _ in
                self?.reloadFetchedResultsController()
            }
            .store(in: &cancellables)
    }

    private func reloadFetchedResultsController() {
        stores.trackerStore.updateFetchedResultsController()
        collection.reloadData()
    }
    
    
    // MARK: - Setup UI and layout
    
    private func setup() {
        view.backgroundColor = .mainColorYP(.whiteYP)
        setCollectionView()
        setNavBarElements()
        setConstraints()
    }
    
    private func setCollectionView() {
        collection.dataSource = self
        collection.delegate = self
        
        collection.register(TrackerCell.self,forCellWithReuseIdentifier: TrackerCell.identifier)
        collection.register(TrackerHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerHeader.identifier)
        
        collection.backgroundColor = .mainColorYP(.whiteYP)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.alwaysBounceVertical = true
    }
    
    private func setNavBarElements() {
        
        lazy var addNewTrackerButton: UIBarButtonItem = {
            let barButton = UIBarButtonItem()
            barButton.tintColor = .mainColorYP(.blackYP)
            barButton.style = .plain
            barButton.image = UIImage(named: "addTrackerIcon42x42")
            barButton.target = self
            barButton.action = #selector(addNewTracker)
            return barButton
        }()
        
        lazy var dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            dateFormatter.dateStyle = .short
            dateFormatter.locale = .current
            return dateFormatter
        }()
        
        lazy var datePicker: UIDatePicker = {
            let datePicker = UIDatePicker()
            datePicker.locale = dateFormatter.locale
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .compact
            datePicker.maximumDate = Date()
            datePicker.addTarget(self, action: #selector(didTapDatePickerButton), for: .valueChanged)
            return datePicker
        }()
        
        title = localization.localized(
            "trackersvc.title",
            comment: "Page title"
        )
        navigationItem.leftBarButtonItem = addNewTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.searchTextField.textColor = .mainColorYP(.grayYP)
        searchController.searchBar.placeholder = localization.localized(
            "trackersvc.search_placeholder.title",
            comment: "Search bar placeholder"
        )
        searchController.searchBar.delegate = self
    }
    
    @objc private func addNewTracker() {
        let vc = TrackerOrEventVC(dependencies: stores)
        vc.trackerVC = self
        present(vc, animated: true)
        analytic.log(event: .click(screen: .main, item: "add_track"))
    }
    
    @objc func didTapDatePickerButton(_ date: UIDatePicker) {
        selectedDate = date.date
        filterResults(with: selectedDate)
    }
    
    private func setConstraints() {
        view.addSubview(collection)
        collection.addSubview(placeholder)
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


// MARK: - DataSource

extension TrackersVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    // Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            LogService.shared.log("Could not dequeue cell as TrackerCell", level: .error)
            return .init()
        }
        
        let trackerData = stores.trackerStore.fetchedResultsControllerForTracker().object(at: indexPath)
        
        if let tracker = stores.trackerStore.tracker(from: trackerData) {
            cell.backgroundShape.backgroundColor = tracker.color
            cell.doneButton.backgroundColor = tracker.color
            cell.titleLabel.text = tracker.title
            cell.emojiLabel.text = tracker.emoji
            cell.delegate = self
            
            // Check if a record exists for the tracker and set the initial done button state accordingly
            let trackerID = tracker.id
            let recordID = stores.recordStore.getRecordIDForToday(forTrackerWithID: trackerID, onDate: selectedDate)
            let recordsCount = stores.recordStore.fetchRecordsCount(forTrackerWithID: trackerID)
            
            cell.daysLabel.text = localization.pluralized(
                "days", count: recordsCount)
            cell.setInitialDoneButtonState(isDone: recordID != nil)
        }
        
        return cell
    }
    
    
    // Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeader.identifier,
            for: indexPath) as? TrackerHeader else { return .init() }
        
        header.categoryLabel.text = fetchedResultsController.sections?[indexPath.section].name
        
        return header
    }
    
    // MARK: - Contextual Menue
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let trackerData: TrackerData = fetchedResultsController.object(at: indexPath)
        
        guard let trackerID = trackerData.id else {
            LogService.shared.log("Error: Tracker ID is nil", level: .error)
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            // "Toggle pin" action
            let isPinned = self.pinService.isTrackerPinned(withId: trackerID)
            
            let togglePinActionTitle = isPinned
            ? self.localization.localized("menu.trackers.unpin", comment: "")
            : self.localization.localized("menu.trackers.pin", comment: "")
            
            let togglePinAction = UIAction(title: togglePinActionTitle) { action in
                if isPinned {
                    self.pinService.unpinTracker(withId: trackerID)
                } else {
                    self.pinService.pinTracker(withId: trackerID)
                }
            }
            
            // "Edit" action
            let localizedEditTitle = self.localization.localized(
                "menu.trackers.edit",
                comment: "Edit tracker option in the context menu"
            )
            let editAction = UIAction(title: localizedEditTitle) { action in
                let trackerData: TrackerData = self.fetchedResultsController.object(at: indexPath)
                let trackerEditVC = EditTrackerVC(dependencies: self.stores, trackerID: trackerData.id!) // ID есть всегда
                self.present(trackerEditVC, animated: true)
            }
            
            // "Delete" action
            let localizedDeleteTitle = self.localization.localized(
                "menu.trackers.delete",
                comment: "Delete tracker option in the context menu"
            )
            let deleteAction = UIAction(title: localizedDeleteTitle, attributes: .destructive) { action in
                self.confirmDeletion(ofTracker: trackerID)
            }
            
            return UIMenu(title: "", children: [togglePinAction, editAction, deleteAction])
        }
    }
    
    private func confirmDeletion(ofTracker trackerID: UUID) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Create "Delete" action
        let deleteTitle = self.localization.localized(
            "submenu.delete.confirm",
            comment: "Delete confirmation"
        )
        let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive) { _ in
            self.stores.trackerStore.deleteTracker(by: trackerID)
            DispatchQueue.main.async {
                self.collection.reloadData()
            }
        }
        alertController.addAction(deleteAction)
        
        let cancelTitle = self.localization.localized(
            "submenu.delete.cancel",
            comment: "Cancel deletion process   ")
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    
}


// MARK: - Layout

extension TrackersVC: UICollectionViewDelegateFlowLayout {
    
    // Section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 12, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .init(9)
    }
    
    // Cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: (collectionView.frame.width - (16 * 2) - 9) / 2, height: 148)
    }
    
    // Header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 18 + 12)
    }
}


// MARK: - Filtering

extension TrackersVC: UISearchResultsUpdating {
    
    internal func updateSearchResults(for searchController: UISearchController) {
        
        guard let textInput = searchController.searchBar.text else { return }
        searchText = textInput
        
        if !searchText.isEmpty {
            filterResults(with: searchText)
        }
    }
    
    private func resetSearchFilter() {
        filterResults(with: selectedDate)
    }
    
    private func filterResults(with date: Date) {
        stores.trackerStore.updatePredicateForWeekDayFilter(date: date)
        reloadCollectionAfterFiltering(filterType: .date)
    }
    
    private func filterResults(with searchText: String) {
        stores.trackerStore.updatePredicateForTextFilter(searchText: searchText)
        reloadCollectionAfterFiltering(filterType: .search)
    }
    
    private func reloadCollectionAfterFiltering(filterType: FilterType) {
        updatePlaceholder(for: filterType)
        collection.reloadData()
    }
    
    
    // MARK: - Placeholder State
    
    private func updatePlaceholder(for filterType: FilterType) {
        switch filterType {
        case .search: placeholder.placeholderType = .noSearchResults
        case .date: placeholder.placeholderType = .noTrackers
        }
        
        let isEmpty = fetchedResultsController.sections?.reduce(0, { $0 + $1.numberOfObjects }) == 0
        placeholder.isHidden = !isEmpty
    }
}


// MARK: - Delegates

// Create tracker
extension TrackersVC: CreateTrackerVCDelegate {
    func didCreateNewTracker(newTracker: Tracker, categoryID: UUID) {
        stores.сategoryStore.add(tracker: newTracker,
                                       toCategoryWithId: categoryID)
        reloadCollectionAfterFiltering(filterType: .date)
    }
}

// Edit tracker
extension TrackersVC: EditTrackerDelegate {
    func didUpdateTracker(tracker: Tracker) {
        reloadCollectionAfterFiltering(filterType: .date)
    }
}

// TrackerCellDelegate (Record tracker)
extension TrackersVC: TrackerCellDelegate {
    
    func didCompleteTracker(_ isDone: Bool, in cell: TrackerCell) {
        analytic.log(event: .click(screen: .main, item: "track"))
        
        guard let indexPath = collection.indexPath(for: cell) else { return }
        let trackerData: TrackerData = fetchedResultsController.object(at: indexPath)
        
        guard let trackerID = trackerData.id else {
            LogService.shared.log("Error: Tracker ID is nil", level: .error)
            return
        }
        
        let recordStore = stores.recordStore
        recordStore.toggleRecord(forTrackerWithID: trackerID, onDate: selectedDate)
    }
    
    func trackerIsDone(trackerID: UUID) -> Bool {
        return stores.recordStore.getRecordIDForToday(forTrackerWithID: trackerID, onDate: selectedDate) != nil
    }
}

// Tracker Store Delegate
extension TrackersVC: TrackerStoreDelegate {
    func trackerStoreDidChangeContent() {
        collection.reloadData()
    }
}

// Searchbar Delegate
extension TrackersVC: UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty ?? true {
            resetSearchFilter()
        }
    }
}
