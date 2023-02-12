import UIKit

final class TrackerVC: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        registerClassesForReuse()
        setSearchBar()
        setConstraints()
        setupNavBar()
        collectionView.dataSource = self
        collectionView.delegate = self
        searchController.searchResultsUpdater = self
    }


    func registerClassesForReuse() {
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
    }


    // Navbar
    func setupNavBar() {

        let addNewTrackerButton: UIBarButtonItem = {
            let image = UIImage(named: "addTrackerIcon42x42")
            let button = UIBarButtonItem(
                image: image,
                style: .plain,
                target: self,
                action: #selector(addNewTracker)
            )
            button.tintColor = .colorYP(.blackYP)
            return button
        }()

        let datePickerButton: UIDatePicker = {
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            picker.preferredDatePickerStyle = .compact
            picker.addTarget(TrackerVC.self, action: #selector (didTapDatePickerButton), for: .valueChanged)
            picker.translatesAutoresizingMaskIntoConstraints = false
            return picker
        }()

        let title = "Трекеры"

        navigationItem.title = title
        navigationItem.leftBarButtonItem = addNewTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePickerButton)
        navigationItem.searchController = searchController
    }

    @objc
    private func addNewTracker() {
    }

    @objc func didTapDatePickerButton() {
    }

    func setSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = true
        //searchController.searchBar.text = "Поиск"
        searchController.searchBar.searchTextField.textColor = .colorYP(.grayYP)
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


// MARK: - Setup UI

extension TrackerVC: UICollectionViewDataSource {
}


// MARK: - DataSource

extension TrackerVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    // Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else { return .init() }

        cell.backgroundShape.backgroundColor = Tracker.mockCase.color
        cell.doneButton.backgroundColor = Tracker.mockCase.color
        cell.titleLabel.text = Tracker.mockCase.title
        cell.emojiLabel.text = Tracker.mockCase.emoji
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

        header.categoryLabel.text = TrackerCategory.mockHome.title

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

extension TrackerVC: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

    }
}


// MARK: - SHOW PREVIEW

import SwiftUI
struct TrackerVCProvider: PreviewProvider {
    static var previews: some View {
        TrackerVC().showPreview()
    }
}
