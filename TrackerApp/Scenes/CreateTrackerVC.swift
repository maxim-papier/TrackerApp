import UIKit

final class CreateTrackerVC: UIViewController, UICollectionViewDelegateFlowLayout {


    // MARK: Tracker creation properties

    var isCreatingEvent: Bool = false

    var selectedTitle: String?
    var selectedCategory: TrackerCategory?
    var selectedSchedule = WeekDaySet(weekDays: [])
    var selectedEmoji: String?
    var selectedColor: SelectionColorStyle?
    var selectedEmojiIndexPath: IndexPath?
    var selectedColorIndexPath: IndexPath?

    weak var delegate: CreateTrackerVCDelegate?


    // MARK: Actual VC properties

    var collectionView: UICollectionView! = nil
    private let listCellItemName: [String] = ["Категория", "Расписание"]
    var readyButton: Button?

    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
        "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]


    // MARK: Core Data

    private var dependencies: DependencyContainer

    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainColorYP(.whiteYP)
        configureCollectionView()
    }


    // MARK: - Setup UI and Collection

    func configureCollectionView() {

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
            label.text = isCreatingEvent ? "Новое событие" : "Новая привычка"
            label.textColor = UIColor.mainColorYP(.blackYP)
            label.font = FontYP.medium16
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let cancelButton = Button(type: .cancel, title: "Отменить") {
            print("CANCEL is tapped")
            self.dismiss(animated: true)
        }

        readyButton = Button(type: .primary(isActive: false), title: "Готово", tapHandler: {
            print("readyButton is ready")
            self.delegate?.didCreateNewTracker(newCategory: self.createNewTracker())
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.dismiss(animated: true, completion: nil)
            }
        })

        let hStack: UIStackView = {
            let stack = UIStackView()
            stack.backgroundColor = .mainColorYP(.whiteYP)
            stack.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
            stack.isLayoutMarginsRelativeArrangement = true
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 8
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()

        collectionView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionView)
        view.addSubview(title)
        view.addSubview(hStack)

        hStack.addArrangedSubview(cancelButton)
        hStack.addArrangedSubview(readyButton!)

        let vInset: CGFloat = 38
        let hInset: CGFloat = 20

        NSLayoutConstraint.activate([

            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),

            collectionView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: vInset),
            collectionView.bottomAnchor.constraint(equalTo: hStack.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            hStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            hStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: hInset),
            hStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -hInset)
        ])

        collectionView.delegate = self
        collectionView.dataSource = self
    }


    func generateLayout() -> UICollectionViewLayout {

        let inputLayout = createInputLayout()
        let listLayout = createListLayout()
        let emojiLayout = createEmojiLayout()
        let colorLayout = createColorLayout()

        return UICollectionViewCompositionalLayout { (sectionNumber, env) ->
            NSCollectionLayoutSection? in

            switch sectionNumber {
            case 0: return inputLayout
            case 1: return listLayout
            case 2: return emojiLayout
            case 3: return colorLayout
            default:
                fatalError("Unsupported section in generateLayout")
            }
        }
    }
}

extension CreateTrackerVC {

    func createInputLayout() -> NSCollectionLayoutSection {

        let height: CGFloat = 75
        let hInset: CGFloat = 16

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(height))

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: hInset, bottom: 0, trailing: hInset)

        return section
    }

    func createListLayout() -> NSCollectionLayoutSection {

        let height: CGFloat = 75
        let hInset: CGFloat = 16

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(height+height))

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 24, leading: hInset, bottom: 32, trailing: hInset)

        return section
    }

    func createEmojiLayout() -> NSCollectionLayoutSection {

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
    }

    func createColorLayout() -> NSCollectionLayoutSection {

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
    }
}


// MARK: - EXTENTIONS

extension CreateTrackerVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 4 }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {

        switch section {
        case 0: return 1
        case 1: return isCreatingEvent ? 1 : 2
        case 2: return emojis.count
        case 3: return SelectionColorStyle.allCases.count
        default: fatalError("Unsupported section in numberOfItemsInSection")
        }
    }

    // Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            return inputCell(for: indexPath, collectionView: collectionView)
        case 1:
            return listCell(for: indexPath, collectionView: collectionView)
        case 2:
            return emojiCell(for: indexPath, collectionView: collectionView)
        case 3:
            return colorCell(for: indexPath, collectionView: collectionView)
        default:
            fatalError("Unsupported section in cellForItemAt")
        }
    }

    func inputCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        let inputCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: InputCell.identifier,
            for: indexPath) as! InputCell

        inputCell.userInputField.placeholder = "Введите название трекера"

        inputCell.textFieldValueChanged = { inputText in
            self.selectedTitle = inputText

            self.isTrackerReadyToBeCreated()
        }

        return inputCell
    }

    func listCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {

        let listCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ListCell.identifier,
            for: indexPath) as! ListCell

        if indexPath.item == 0 {
            listCell.buttonPosition = isCreatingEvent ? .single : .first
            listCell.subtitleLabel.text = selectedCategory?.name
        } else if indexPath.item == 1 && !isCreatingEvent {
            listCell.buttonPosition = .last
            if !selectedSchedule.weekDays.isEmpty {
                let days = selectedSchedule.weekDays.map { $0.shortLabel }
                print("DAYS \(days)")
                let daysString = days.joined(separator: ", ")
                listCell.subtitleLabel.text = daysString
            }
        }

        listCell.titleLabel.text = listCellItemName[indexPath.item]

        return listCell
    }

    func emojiCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        let emojiCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiCell.identifier,
            for: indexPath) as! EmojiCell

        emojiCell.emojiLabel.text = emojis[indexPath.row]
        emojiCell.backgroundShape.layer.cornerRadius = 16

        return emojiCell
    }

    func colorCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        let colorCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCell.identifier,
            for: indexPath) as! ColorCell

        return colorCell
    }

    // Header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Header.identifier,
            for: indexPath) as! Header

        switch indexPath.section {
        case 0, 1: header.isHidden = true
        case 2: header.sectionLabel.text = "Emoji"
        case 3: header.sectionLabel.text = "Цвет"
        default:
            fatalError("Unsupported section in viewForSupplementaryElementOfKind")
        }
        return header
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
        case 0: handleInputSelection()
        case 1: handleListSelection(at: indexPath)
        case 2: handleEmojiSelection(at: indexPath)
        case 3: handleColorSelection(at: indexPath)
        default: break
        }

        collectionView.deselectItem(at: indexPath, animated: false)

    }

    private func handleInputSelection() {
        print("Ready to input")
    }

    private func handleListSelection(at indexPath: IndexPath) {

        if indexPath.row == 0 {
            let vc = CategoryVC(dependencies: dependencies)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            let vc = SchedulerVC(selectedDays: Array(selectedSchedule.weekDays))
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }

    private func handleEmojiSelection(at indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }

        if let selectedCell = collectionView.cellForItem(at: selectedEmojiIndexPath ?? IndexPath(item: -1, section: 0)) as? EmojiCell {
            selectedCell.backgroundShape.backgroundColor = UIColor.clear
        }

        cell.backgroundShape.backgroundColor = UIColor.mainColorYP(.lightGrayYP)

        selectedEmojiIndexPath = indexPath
        selectedEmoji = emojis[indexPath.row]

        isTrackerReadyToBeCreated()
    }

    private func handleColorSelection(at indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }

        let colorIndex = indexPath.row % SelectionColorStyle.allCases.count
        let color = UIColor.selectionColorYP(SelectionColorStyle.allCases[colorIndex])

        if let selectedColorIndexPath = collectionView.cellForItem(at: selectedColorIndexPath ?? IndexPath(item: -1, section: 0)) as? ColorCell {
            selectedColorIndexPath.backgroundShape.layer.borderColor = UIColor.clear.cgColor
        }

        cell.backgroundShape.layer.borderColor = color?.withAlphaComponent(0.3).cgColor

        selectedColorIndexPath = indexPath
        selectedColor = SelectionColorStyle.allCases[indexPath.row]

        isTrackerReadyToBeCreated()
    }

}

// MARK: - Add Scheduler Delegate

extension CreateTrackerVC: AddSchedulerDelegate {

    func didUpdateSelectedDays(selectedDays: WeekDaySet) {
        self.selectedSchedule = selectedDays

        isTrackerReadyToBeCreated()

        let sectionToReload = 1
        collectionView.reloadSections(IndexSet(integer: sectionToReload))
    }
}


// MARK: - Create Tracker

extension CreateTrackerVC {

    func isTrackerReadyToBeCreated() {
        guard let title = selectedTitle, !title.isEmpty,
              let category = selectedCategory,
              let emoji = selectedEmoji,
              let color = selectedColor else {
            readyButton?.isActive = false
            return
        }

        switch isCreatingEvent {
        case false:
            guard !selectedSchedule.weekDays.isEmpty else {
                readyButton?.isActive = false
                return
            }
        case true:
            break
        }

        print("DATA IS READY TO SAVE:")
        print("selectedTitle === \(title)")
        print("selectedCategory === \(category)")
        print("selectedEmoji === \(emoji)")
        print("selectedColor === \(color)")
        print("selectedSchedule === \(selectedSchedule)")

        readyButton?.isActive = true
    }

    func createNewTracker() -> TrackerCategory {

        // Использую force unwrap, так как уже проверил,
        // что значения существуют в методе isTrackerReadyToBeCreated()
        let title: String = selectedTitle!
        let emoji: String = selectedEmoji!
        let color: UIColor = UIColor.selectionColorYP(selectedColor!)!
        let day: Set<WeekDay>? = Set(selectedSchedule.weekDays)


        // Создаем новый трекер
        let newTracker = Tracker(title: title, emoji: emoji, color: color, day: day)

        // Создаем новую категорию для нового трекера
        let newCategory = TrackerCategory(name: selectedCategory?.name ?? "", trackers: [newTracker])

        print("NEWCATEGORY === \(newCategory)")

        return newCategory
    }
}

extension CreateTrackerVC: CategorySelectionDelegate {
    func categorySelected(category: TrackerCategory) {
        selectedCategory = category
        let sectionToReload = 1
        collectionView.reloadSections(IndexSet(integer: sectionToReload))
    }
}


// MARK: - PROTOCOL

protocol CreateTrackerVCDelegate: AnyObject {
    func didCreateNewTracker(newCategory: TrackerCategory)
}

protocol CategorySelectionDelegate: AnyObject {
    func categorySelected(category: TrackerCategory)
}
