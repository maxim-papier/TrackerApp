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


    @objc func labelMenuTapped() {
        // Выполняем действия, которые необходимо выполнить при нажатии на labelMenu
        print("labelMenu tapped")
    }


    func configureCollectionView() {

        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())

        // Register
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        collectionView.register(EmojiHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiHeader.identifier)
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.identifier)

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

        let backgroundShape: UIView = {
            let view = UIView()
            view.layer.cornerRadius = 16
            view.clipsToBounds = true
            view.backgroundColor = UIColor.mainColorYP(.backgroundYP)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        let userInputField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Введите название трекера"
            textField.textAlignment = .left
            textField.translatesAutoresizingMaskIntoConstraints = false
            return textField
        }()

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        view.addSubview(title)
        view.addSubview(backgroundShape)
        backgroundShape.addSubview(userInputField)

        let hInset: CGFloat = 16
        let vInset: CGFloat = 38

        NSLayoutConstraint.activate([

            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),

            backgroundShape.topAnchor.constraint(equalTo: title.bottomAnchor, constant: vInset),
            backgroundShape.heightAnchor.constraint(equalToConstant: 75),
            backgroundShape.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            backgroundShape.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            userInputField.centerYAnchor.constraint(equalTo: backgroundShape.centerYAnchor),
            userInputField.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: hInset),
            userInputField.trailingAnchor.constraint(equalTo: backgroundShape.trailingAnchor, constant: hInset),

            collectionView.topAnchor.constraint(equalTo: userInputField.bottomAnchor, constant: vInset),
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

            case 0: // ListCell
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(75))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(75+75))
                let group: NSCollectionLayoutGroup

                let itemsCount = 2

                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.vertical(
                        layoutSize: groupSize,
                        repeatingSubitem: item,
                        count: itemsCount)
                } else {
                    group = NSCollectionLayoutGroup.vertical(
                        layoutSize: groupSize,
                        subitem: item,
                        count: itemsCount)
                }

                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 16, bottom: 32, trailing: 16)

                return section

            case 1, 2:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/6),
                    heightDimension: .fractionalWidth(1/6))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1/6))
                let group: NSCollectionLayoutGroup

                let itemsCount = self.emojis.count

                if #available(iOS 16.0, *) {
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: groupSize,
                        repeatingSubitem: item,
                        count: itemsCount / 3)
                } else {
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: groupSize,
                        subitem: item,
                        count: itemsCount / 3)
                }

                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: 18, bottom: 24, trailing: 18)

                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(18)
                )

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )

                section.boundarySupplementaryItems = [header]
                return section

            default:
                fatalError("Unsupported section in generateLayout")
            }
        }
    }
}

extension CreateTrackerVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 3 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return emojis.count
        case 2: return SelectionColorStyle.allCases.count
        default: fatalError("Unsupported section in numberOfItemsInSection")
        }
    }


    // Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cellEmoji = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiCell.identifier,
            for: indexPath
        ) as? EmojiCell else { return .init() }

        guard let cellList = collectionView.dequeueReusableCell(
            withReuseIdentifier: ListCell.identifier,
            for: indexPath
        ) as? ListCell else { return .init() }

        switch indexPath.section {

        case 0:
#warning("Доделать логику: ячейка одна, ячейка первая, ячейка средняя, ячейка последняя")
            // Feed cell
            if indexPath.item == 0 {
                cellList.labelMenu.text = "Категория"
                cellList.layer.masksToBounds = true
                cellList.layer.cornerRadius = 16
                cellList.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            // Настроить скругление углов для последней ячейки
            else if indexPath.item == 1 {
                cellList.labelMenu.text = "Расписание"
                cellList.layer.masksToBounds = true
                cellList.layer.cornerRadius = 16
                cellList.separator.isHidden = true
                cellList.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
            return cellList

        case 1:
            cellEmoji.emojiLabel.text = emojis[indexPath.row]
            cellEmoji.backgroundShape.layer.cornerRadius = 16
            return cellEmoji

        case 2:
            cellEmoji.backgroundShape.layer.cornerRadius = 8
            cellEmoji.backgroundShape.layer.borderWidth = 3
            cellEmoji.backgroundShape.layer.borderColor = UIColor.clear.cgColor
            return cellEmoji

        default:
            fatalError("Unsupported section in cellForItemAt")
        }
    }

    // Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: EmojiHeader.identifier,
            for: indexPath
        ) as? EmojiHeader else { return .init() }


        switch indexPath.section {

        case 0:
            header.isHidden = true
            return header
        case 1:
            header.sectionLabel.text = "Emoji"
            return header
        case 2:
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

        if indexPath.section == 2 {

            if let selectionCell = cell as? EmojiCell {

                let selectionColor = SelectionColorStyle.allCases[
                    indexPath.row % SelectionColorStyle.allCases.count
                ]
                selectionCell.emojiLabel.backgroundColor = UIColor.selectionColorYP(selectionColor)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let vc = AddCategory()
                present(vc, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                let vc = AddScheduler()
                present(vc, animated: true, completion: nil)
            }
            collectionView.deselectItem(at: indexPath, animated: false)

        case 1:
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
                if let selectedCell = collectionView.cellForItem(at: selectedEmoji ?? IndexPath(item: -1, section: 0)) as? EmojiCell {
                    selectedCell.backgroundShape.backgroundColor = UIColor.clear
                }
                cell.backgroundShape.backgroundColor = UIColor.mainColorYP(.lightGrayYP)
                selectedEmoji = indexPath
            }

        case 2:
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
                let colorIndex = indexPath.row % SelectionColorStyle.allCases.count
                let color = UIColor.selectionColorYP(SelectionColorStyle.allCases[colorIndex])
                if let selectedColor = collectionView.cellForItem(at: selectedColor ?? IndexPath(item: -1, section: 0)) as? EmojiCell {
                    selectedColor.backgroundShape.backgroundColor = UIColor.clear
                    selectedColor.backgroundShape.layer.borderColor = UIColor.clear.cgColor
                }
                cell.backgroundShape.layer.borderColor = color?.cgColor
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
