import UIKit

final class CreateTrackerVC: UIViewController, UICollectionViewDelegateFlowLayout {

    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    var selectedEmoji: IndexPath?
    var selectedColor: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainColorYP(.whiteYP)
        configureCollectionView()
    }

    func configureCollectionView() {

        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())

        // Register
        collectionView.register(
            Header.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Header.identifier
        )
        collectionView.register(
            EmojiCell.self,
            forCellWithReuseIdentifier: EmojiCell.identifier
        )
        collectionView.register(
            ListCell.self,
            forCellWithReuseIdentifier: ListCell.identifier
        )
        collectionView.register(
            InputCell.self,
            forCellWithReuseIdentifier: InputCell.identifier)
        collectionView.register(
            ColorCell.self,
            forCellWithReuseIdentifier: ColorCell.identifier)

        // Setup UI
        collectionView.backgroundColor = UIColor.mainColorYP(.whiteYP)

        let title: UILabel = {
            let label = UILabel()
            label.text = "Новая привычка"
            label.textColor = UIColor.mainColorYP(.blackYP)
            label.font = FontYP.medium16
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        view.addSubview(title)

        let vInset: CGFloat = 38

        NSLayoutConstraint.activate([

            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),

            collectionView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: vInset),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    func generateLayout() -> UICollectionViewLayout {

        return UICollectionViewCompositionalLayout { (sectionNumber, env) ->
            NSCollectionLayoutSection? in

            switch sectionNumber {

            case 0: // Input
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(75))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(75))

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

                return section


            case 1: // ListCell
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(75))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(75+75))

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 16, bottom: 32, trailing: 16)

                return section

            case 2: // Emojis
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/6),
                    heightDimension: .fractionalWidth(1/6))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1/6))

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item])


                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18)

                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(18))

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top)

                section.boundarySupplementaryItems = [header]
                return section

            case 3: // Colors
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/6),
                    heightDimension: .fractionalWidth(1/6))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 0, leading: 0, bottom: 5, trailing: 5)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(46))

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18)

                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(18))

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top)

                section.boundarySupplementaryItems = [header]
                

                return section

            default:
                fatalError("Unsupported section in generateLayout")
            }
        }
    }
}

extension CreateTrackerVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 4 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return emojis.count
        case 3: return SelectionColorStyle.allCases.count
        default: fatalError("Unsupported section in numberOfItemsInSection")
        }
    }

    // Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: UICollectionViewCell

        switch indexPath.section {

        case 0:
            let inputCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InputCell.identifier,
                for: indexPath) as! InputCell
            inputCell.userInputField.placeholder = "Введите название трекера"
            cell = inputCell

        case 1:
            let listCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ListCell.identifier,
                for: indexPath) as! ListCell
            if indexPath.item == 0 {
                listCell.labelMenu.text = "Категория"
                listCell.layer.masksToBounds = true
                listCell.layer.cornerRadius = 16
                listCell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if indexPath.item == 1 {
                listCell.labelMenu.text = "Расписание"
                listCell.layer.masksToBounds = true
                listCell.layer.cornerRadius = 16
                listCell.separator.isHidden = true
                listCell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            cell = listCell

        case 2:
            let emojiCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCell.identifier,
                for: indexPath) as! EmojiCell
            emojiCell.emojiLabel.text = emojis[indexPath.row]
            emojiCell.backgroundShape.layer.cornerRadius = 16
            cell = emojiCell

        case 3:
            let colorCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCell.identifier,
                for: indexPath) as! ColorCell
            cell = colorCell

        default:
            fatalError("Unsupported section in cellForItemAt")
        }
        return cell
    }

    // Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Header.identifier,
            for: indexPath
        ) as? Header else { return .init() }

        switch indexPath.section {

        case 0:
            header.isHidden = true
            return header
        case 1:
            header.isHidden = true
            return header
        case 2:
            header.sectionLabel.text = "Emoji"
            return header
        case 3:
            header.sectionLabel.text = "Цвет"
            return header
        default:
            fatalError("Unsupported section in viewForSupplementaryElementOfKind")
        }
    }
}


extension CreateTrackerVC: UICollectionViewDelegate {

    // Set colors for Colors section
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if indexPath.section == 3 {
            if let selectionCell = cell as? ColorCell {
                let selectionColor = SelectionColorStyle.allCases[
                    indexPath.row % SelectionColorStyle.allCases.count]
                selectionCell.innerShape.backgroundColor = UIColor.selectionColorYP(selectionColor)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch indexPath.section {

        case 0:
            print("PPP")

        case 1:
            if indexPath.row == 0 {
                let vc = AddCategory()
                present(vc, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                let vc = AddScheduler()
                present(vc, animated: true, completion: nil)
            }
            collectionView.deselectItem(at: indexPath, animated: false)

        case 2:
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
                if let selectedCell = collectionView.cellForItem(at: selectedEmoji ?? IndexPath(item: -1, section: 0)) as? EmojiCell {
                    selectedCell.backgroundShape.backgroundColor = UIColor.clear
                }
                cell.backgroundShape.backgroundColor = UIColor.mainColorYP(.lightGrayYP)
                selectedEmoji = indexPath
            }

        case 3:
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
                let colorIndex = indexPath.row % SelectionColorStyle.allCases.count
                let color = UIColor.selectionColorYP(SelectionColorStyle.allCases[colorIndex])
                if let selectedColor = collectionView.cellForItem(at: selectedColor ?? IndexPath(item: -1, section: 0)) as? ColorCell {
                    selectedColor.backgroundShape.layer.borderColor = UIColor.clear.cgColor
                }
                cell.backgroundShape.layer.borderColor = color?.withAlphaComponent(0.3).cgColor
                selectedColor = indexPath
            }

        default:
            break
        }
    }
}


// MARK: - SHOW PREVIEW

import SwiftUI
struct CreateTrackerVCProvider: PreviewProvider {
    static var previews: some View {
        CreateTrackerVC().showPreview()
    }
}
