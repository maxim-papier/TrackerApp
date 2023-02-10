import UIKit

final class TrackerVC: UIViewController, UICollectionViewDataSource {

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.colorYP(.grayYP)
        setUp()
    }

    private func setUp() {
        registerClassesForReuse()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        setConstraints()
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.backgroundColor = .darkGray
    }

    private func registerClassesForReuse() {

        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }
}


// MARK: - DataSource

extension TrackerVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

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
}


// MARK: - Layout

extension TrackerVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return .init(width: (collectionView.frame.width - 9) / 2, height: 148)
    }
}



// MARK: - SHOW PREVIEW


import SwiftUI
struct ViewControllerProvider: PreviewProvider {
    static var previews: some View {
        TrackerVC().showPreview()
    }
}
