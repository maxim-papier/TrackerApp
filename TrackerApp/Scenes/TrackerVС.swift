import UIKit

final class TrackerVC: UIViewController {

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private var categories: [TrackerCategory] = [.mockCategory1, .mockCategory2]
    private var filteredCategories: [TrackerCategory] = []
    private var selectedDate = Date()
    private var completedTrackers: [TrackerRecord] = []

    private let searchController = UISearchController(searchResultsController: nil)
    private var searchText = ""
    // private var isSearchBarEmpty: Bool { return searchController.searchBar.text?.isEmpty ?? true }
    // private var isFiltering: Bool { return searchController.isActive && !isSearchBarEmpty } //

    var placeholder = PlaceholderType.noSearchResults.placeholder

    init() { super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("There is no storyboard") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let vc = TrackerOrEventVC()
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
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfSections = filteredCategories.indices.contains(section) ? filteredCategories[section].trackers.count : 0
        return numberOfSections
    }
    
    // Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let show: Tracker = filteredCategories[indexPath.section].trackers[indexPath.item]

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath) as? TrackerCell else { return .init() }

        cell.backgroundShape.backgroundColor = show.color
        cell.doneButton.backgroundColor = show.color
        cell.titleLabel.text = show.title
        cell.emojiLabel.text = show.emoji
        cell.daysLabel.text = "0 дней"
        cell.delegate = self
        
        return cell
    }
    
    // Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeader.identifier,
            for: indexPath) as? TrackerHeader else { return .init() }

        header.categoryLabel.text = filteredCategories[indexPath.section].name
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
    
    private func filterResults(with searchText: String) {
        
        // Reset array to be empty
        filteredCategories = []
        
        for category in categories {
            // Store the relevant trackers
            var filteredTrackers: [Tracker] = []
            
            for tracker in category.trackers {
                if tracker.title.lowercased().contains(searchText.lowercased()) {
                    filteredTrackers.append(tracker)
                }
            }
            // If there are any "filteredTrackers" in this "category",
            // we add this "category" to the "filteredCategories" array
            if filteredTrackers.count > 0 {
                filteredCategories.append(TrackerCategory(name: category.name, trackers: filteredTrackers))
            }
        }
        reloadCollectionAfterSearch()
    }

    private func filterResults(with date: Date) {

        filteredCategories = []

        let selectedWeekDay = Calendar.current.component(.weekday, from: date)
        guard let selectedWeekDayEnum = WeekDay(rawValue: selectedWeekDay) else { return }

        for category in categories {
            var filteredTrackers: [Tracker] = []
            for tracker in category.trackers {
                if let day = tracker.day, day.contains(selectedWeekDayEnum) {
                    filteredTrackers.append(tracker)
                }
            }
            if filteredTrackers.count > 0 {
                filteredCategories.append(TrackerCategory(name: category.name, trackers: filteredTrackers))
            }
        }
        reloadCollectionAfterPickingDate()
    }

    private func reloadCollectionAfterSearch() {

        placeholder.placeholderType = .noSearchResults

        switch filteredCategories.isEmpty {
        case true: placeholder.isHidden = false
        case false: placeholder.isHidden = true
        }
        collectionView.reloadData()
    }

    private func reloadCollectionAfterPickingDate() {

        placeholder.placeholderType = .noTrackers

        switch filteredCategories.isEmpty {
        case true: placeholder.isHidden = false
        case false: placeholder.isHidden = true
        }
        collectionView.reloadData()
    }

}

// MARK: - CreateTrackerVC delegate

extension TrackerVC: CreateTrackerVCDelegate {

    func didCreateNewTracker(newCategory: TrackerCategory) {

        guard let tracker = newCategory.trackers.first else {
            fatalError("TrackerVC says: 'There is no tracker in the new category'")
        }

        addTrackerToCategory(tracker: tracker, categoryName: newCategory.name)
    }

    func addTrackerToCategory(tracker: Tracker, categoryName: String) {

        var trackersForAddedCategory = [Tracker]()
        var existingCategories = categories

        // 0. нашёл такую же категорию
        let existingCategory = categories.first { $0.name == categoryName }

        // 1. достал трекеры из старой категории
        if let existingCategory {
            for tracker in existingCategory {
                trackersForAddedCategory.append(tracker)
            }

            // 2. добавил туда свой трекер,
            trackersForAddedCategory.append(tracker)
        }

        // 4. создал новую категорию с именем и обновленным списком категорий
        let categoryWithNewTracker: TrackerCategory = .init(name: categoryName, trackers: trackersForAddedCategory)

        // 5. Заменил старую категорию на новую
        if let index = existingCategories.firstIndex(where: { $0.name == categoryName }) {
            existingCategories[index] = categoryWithNewTracker
        }

        categories = existingCategories
        filterResults(with: selectedDate)
    }
}

// MARK: - TrackerCellDelegate

extension TrackerVC: TrackerCellDelegate {

    func didCompleteTracker(_ isDone: Bool, in cell: TrackerCell) {

        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let trackerID = filteredCategories[indexPath.section].trackers[indexPath.item].id

        if let index = completedTrackers.firstIndex(where: { $0.id == trackerID }) {
            completedTrackers.remove(at: index)
        } else {
            let record = TrackerRecord(id: trackerID, date: selectedDate)
            completedTrackers.append(record)
        }
        print("COMPLETE TRACKERS === \(completedTrackers)")
    }
}


// MARK: - SHOW PREVIEW

import SwiftUI
struct TrackerVCProvider: PreviewProvider {
    static var previews: some View {
        TrackerVC().showPreview()
    }
}
