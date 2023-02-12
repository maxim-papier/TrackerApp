import UIKit

final class TrackerVC: UIViewController {

    let trackers: [Tracker] = TrackerCategory.mockCategory1.trackers
    var filteredTrackers: [Tracker] = []
    let categories: [TrackerCategory] = [.mockCategory1, .mockCategory2]


    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }


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
        setConstraints()

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

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    @objc
    private func addNewTracker() {
    }

    @objc func didTapDatePickerButton() {
    }

    private func setConstraints() {

        view.backgroundColor = .colorYP(.whiteYP)
        collectionView.backgroundColor = .colorYP(.whiteYP)

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}


// MARK: - DataSource

extension TrackerVC: UICollectionViewDelegate, UICollectionViewDataSource {


    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return isFiltering ? filteredTrackers.count : categories[section].trackers.count
    }

    // Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else { return .init() }

        let show: Tracker

        if isFiltering {
            show = filteredTrackers[indexPath.row]
        } else {
            show = categories[indexPath.section].trackers[indexPath.item]
            print("SECTION :::: \(categories[indexPath.section])")
            print("ROW :::: \(trackers[indexPath.row])")
        }

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
        print(categories[indexPath.section].title)

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

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        filteringContentForSearchText(searchText)
    }

    func filteringContentForSearchText(_ searchText: String) {
        print("LOOKING FOR :::: \(searchText)")
        filteredTrackers = trackers.filter { (tracker: Tracker) -> Bool in
            return tracker.title.lowercased().contains(searchText.lowercased())
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
