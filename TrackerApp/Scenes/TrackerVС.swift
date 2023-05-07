import UIKit

enum FilterType {
    case search
    case date
}

final class TrackerVC: UIViewController {

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private var selectedDate = Date()
    private var completedTrackers: [TrackerRecord] = []

    private let searchController = UISearchController(searchResultsController: nil)
    private var searchText = ""

    var placeholder = PlaceholderType.noSearchResults.placeholder


    // CoreData properties

    weak var delegate: TrackerStoreDelegate?
    private var dependencies: DependencyContainer
    private lazy var fetchedResultsController = {
        dependencies.fetchedResultsControllerForTrackers
    }()

    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dependencies.trackerStore.setupFetchedResultsController()
        dependencies.trackerStore.delegate = self
        filterResults(with: selectedDate)
        setup()
    }


    private func setup() {
        view.backgroundColor = .mainColorYP(.whiteYP)

        setCollectionView()
        setNavBarElements()
        setConstraints()
    }

    private func setCollectionView() {

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(TrackerCell.self,forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerHeader.identifier)

        collectionView.backgroundColor = .mainColorYP(.whiteYP)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
    }
    
    private func setNavBarElements() {
        
        let addNewTrackerButton: UIBarButtonItem = {
            let barButton = UIBarButtonItem()
            barButton.tintColor = .mainColorYP(.blackYP)
            barButton.style = .plain
            barButton.image = UIImage(named: "addTrackerIcon42x42")
            barButton.target = self
            barButton.action = #selector(addNewTracker)
            return barButton
        }()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        let datePicker = UIDatePicker()
        datePicker.locale = dateFormatter.locale
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(didTapDatePickerButton), for: .valueChanged)

        title = "Трекеры"
        navigationItem.leftBarButtonItem = addNewTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.searchTextField.textColor = .mainColorYP(.grayYP)
        searchController.searchBar.placeholder = "Поиск"
    }
    
    @objc private func addNewTracker() {
        let vc = TrackerOrEventVC(dependencies: dependencies)
        vc.trackerVC = self
        present(vc, animated: true)
    }
    
    @objc func didTapDatePickerButton(_ date: UIDatePicker) {
        selectedDate = date.date
        filterResults(with: selectedDate)
    }

    private func setConstraints() {
        view.addSubview(collectionView)
        collectionView.addSubview(placeholder)

        placeholder.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


// MARK: - DataSource

extension TrackerVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return dependencies.trackerStore.fetchedResultsControllerForTracker().fetchedObjects?.count ?? 0
        }
    
    // Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell

        let trackerData = dependencies.trackerStore.fetchedResultsControllerForTracker().object(at: indexPath)

        if let tracker = dependencies.trackerStore.tracker(from: trackerData) {
            cell.backgroundShape.backgroundColor = tracker.color
            cell.doneButton.backgroundColor = tracker.color
            cell.titleLabel.text = tracker.title
            cell.emojiLabel.text = tracker.emoji

            cell.daysLabel.text = "0 дней"

            cell.delegate = self
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
}


// MARK: - Layout

extension TrackerVC: UICollectionViewDelegateFlowLayout {
    
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


// MARK: - SEARCH LOGIC

extension TrackerVC: UISearchResultsUpdating {
    
    internal func updateSearchResults(for searchController: UISearchController) {

        guard let textInput = searchController.searchBar.text else { return }
        searchText = textInput

        if !searchText.isEmpty {
            filterResults(with: searchText)
        }
    }
    
    private func filterResults(with date: Date) {
        dependencies.trackerStore.updatePredicateForWeekDayFilter(date: date)
        reloadCollectionAfterFiltering(filterType: .date)
    }

    private func filterResults(with searchText: String) {
        dependencies.trackerStore.updatePredicateForTextFilter(searchText: searchText)
        reloadCollectionAfterFiltering(filterType: .search)
    }


    private func reloadCollectionAfterFiltering(filterType: FilterType) {
        updatePlaceholder(for: filterType)
        collectionView.reloadData()
    }

    private func updatePlaceholder(for filterType: FilterType) {
        switch filterType {
        case .search: placeholder.placeholderType = .noSearchResults
        case .date: placeholder.placeholderType = .noTrackers
        }

        let isEmpty = fetchedResultsController.sections?.reduce(0, { $0 + $1.numberOfObjects }) == 0
        placeholder.isHidden = !isEmpty
    }
}

// MARK: - CreateTrackerVC delegate

extension TrackerVC: CreateTrackerVCDelegate {

    
    func didCreateNewTracker(newTracker: Tracker, categoryID: UUID) {
        
        let categoryStore = dependencies.trackerCategoryStore
        
        categoryStore.addTrackerToCategory(tracker: newTracker, categoryId: categoryID)

    }
}


// MARK: - TrackerCellDelegate

extension TrackerVC: TrackerCellDelegate {

    func didCompleteTracker(_ isDone: Bool, in cell: TrackerCell) {

        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let trackerData: TrackerData = fetchedResultsController.object(at: indexPath)

        guard let trackerID = trackerData.id else {
            print("Error: Tracker ID is nil")
            return
        }

        if let index = completedTrackers.firstIndex(where: { $0.id == trackerID }) {
            completedTrackers.remove(at: index)
        } else {
            let record = TrackerRecord(id: trackerID, date: selectedDate)
            completedTrackers.append(record)
            dependencies.trackerRecordStore.addRecord(forTrackerWithID: trackerID)
        }
        print("COMPLETE TRACKERS === \(completedTrackers)")
    }
}


// MARK: - Tracker Store Delegate

extension TrackerVC: TrackerStoreDelegate {

    func trackerStoreDidChange(changeType: TrackerStoreChangeType, object: Any, at indexPath: IndexPath?, newIndexPath: IndexPath?) {

        switch changeType {

        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            collectionView.insertItems(at: [newIndexPath])

        case .delete:
            guard let indexPath = indexPath else { return }
            collectionView.deleteItems(at: [indexPath])

        case .update:
            guard let indexPath = indexPath else { return }
            collectionView.reloadItems(at: [indexPath])

        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            collectionView.moveItem(at: indexPath, to: newIndexPath)
        }
    }

}
