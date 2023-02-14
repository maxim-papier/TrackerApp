import UIKit

final class TrackerVC: UIViewController {
    
    private let categories: [TrackerCategory] = [.mockCategory1, .mockCategory2]
    private var filteredCategories: [TrackerCategory] = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var isSearchBarEmpty: Bool { return searchController.searchBar.text?.isEmpty ?? true } //
    var isFiltering: Bool { return searchController.isActive && !isSearchBarEmpty } //

    private var searchText = ""
    private var selectedDate = Date()

    private let placeholder = PlaceholderType.noSearchResults.placeholder
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())


    init() {
        super.init(nibName: nil, bundle: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.searchTextField.textColor = .colorYP(.grayYP)
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterTrackersByDate(selectedDate)
        setup()
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
        addNewTrackerButton.tintColor = .colorYP(.blackYP)
        
        title = "Трекеры"
        navigationItem.leftBarButtonItem = addNewTrackerButton
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(didTapDatePickerButton), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    @objc
    private func addNewTracker() {
    }
    
    @objc func didTapDatePickerButton(_ date: UIDatePicker) {
        selectedDate = date.date
        filterTrackersByDate(selectedDate)
    }

    private func setUIAndConstraints() {

        view.backgroundColor = .colorYP(.whiteYP)
        collectionView.backgroundColor = .colorYP(.whiteYP)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

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
        
        header.categoryLabel.text = categories[indexPath.section].title
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
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
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
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
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


// MARK: - SHOW PREVIEW

import SwiftUI
struct TrackerVCProvider: PreviewProvider {
    static var previews: some View {
        TrackerVC().showPreview()
    }
}
