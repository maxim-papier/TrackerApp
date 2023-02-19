import UIKit

final class TrackerVC: UIViewController {

    var categories: [TrackerCategory] = [.mockCategory1, .mockCategory2]

    private var filteredCategories: [TrackerCategory] = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchBarEmpty: Bool { return searchController.searchBar.text?.isEmpty ?? true } //
    var isFiltering: Bool { return searchController.isActive && !isSearchBarEmpty } //

    private var searchText = ""
    private var selectedDate = Date()

    private var placeholder = PlaceholderType.noSearchResults.placeholder
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())


    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterTrackersByDate(selectedDate)
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.searchController = searchController
    }

    
    private func setup() {
        collectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.identifier
        )
        collectionView.register(
            TrackerHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeader.identifier
        )
        
        setupNavBar()
        setUIAndConstraints()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchController.searchResultsUpdater = self
    }
    
    private func setupNavBar() {
        
        let addNewTrackerButton = UIBarButtonItem(
            image: UIImage(named: "addTrackerIcon42x42"),
            style: .plain,
            target: self,
            action: #selector(addNewTracker)
        )
        addNewTrackerButton.tintColor = .mainColorYP(.blackYP)
        
        title = "Трекеры"
        navigationItem.leftBarButtonItem = addNewTrackerButton
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(didTapDatePickerButton), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.searchTextField.textColor = .mainColorYP(.grayYP)
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
    }
    
    @objc
    private func addNewTracker() {
        let vc = TrackerOrEventVC()
        vc.trackerVC = self
        present(vc, animated: true)
    }
    
    @objc func didTapDatePickerButton(_ date: UIDatePicker) {
        selectedDate = date.date
        filterTrackersByDate(selectedDate)
    }

    private func setUIAndConstraints() {

        view.backgroundColor = .mainColorYP(.whiteYP)
        collectionView.backgroundColor = .mainColorYP(.whiteYP)

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
        return filteredCategories.indices.contains(section) ? filteredCategories[section].trackers.count : 0
    }
    
    // Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else { return .init() }
        
        let show: Tracker
        
        show = filteredCategories[indexPath.section].trackers[indexPath.item]

        cell.backgroundShape.backgroundColor = show.color
        cell.doneButton.backgroundColor = show.color
        cell.titleLabel.text = show.title
        cell.emojiLabel.text = show.emoji
        cell.daysLabel.text = "XX дней"
        
        return cell
    }
    
    // Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeader.identifier,
            for: indexPath
        ) as? TrackerHeader else { return .init() }
        
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


// MARK: - Setting up search

extension TrackerVC: UISearchResultsUpdating {
    
    internal func updateSearchResults(for searchController: UISearchController) {
        guard let textInput = searchController.searchBar.text else { return }
        searchText = textInput
        switch searchText.isEmpty {
        case true: break
        case false: filteringContentForSearchText(searchText)
        }
    }
    
    private func filteringContentForSearchText(_ searchText: String) {
        
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
        reloadCollection()
    }

    private func filterTrackersByDate(_ date: Date) {

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
        reloadCollection()
    }

    private func reloadCollection() {

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

        guard let tracker = newCategory.trackers.first else { fatalError("TrackerVC says: 'There is no tracker in the new category'") }

        addTrackerToCategory(tracker: tracker, categoryName: newCategory.name)
        reloadCollection()
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
    }
}



// MARK: - SHOW PREVIEW

import SwiftUI
struct TrackerVCProvider: PreviewProvider {
    static var previews: some View {
        TrackerVC().showPreview()
    }
}
