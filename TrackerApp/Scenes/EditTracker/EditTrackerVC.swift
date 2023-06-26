import UIKit

private enum Section: Int, CaseIterable {
    case input = 0
    case list
    case emoji
    case color
}

final class EditTrackerVC: UIViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: Tracker creation properties
    private var isCreatingEvent: Bool = false
    
    private let tracker: Tracker?
    
    private var selectedTitle: String?
    private var selectedCategory: Category?
    private var selectedSchedule = WeekDaySet(weekDays: [])
    private var selectedEmoji: String?
    private var selectedColor: SelectionColorStyle?
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    
    weak var delegate: CreateTrackerVCDelegate?
    
    // MARK: Actual VC properties
    
    private var collectionView: UICollectionView! = nil
    private let listCellItemName: [String] = ["Категория", "Расписание"]
    private var readyButton: Button?
    
    
    // MARK: Core Data
    
    private var dependencies: DependencyContainer
    
    init(dependencies: DependencyContainer,
         tracker: Tracker) {
        self.dependencies = dependencies
        self.tracker = tracker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Viewcontroller Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainColorYP(.whiteYP)
        
        if let tracker = tracker {
            selectedTitle = tracker.title
            selectedSchedule = WeekDaySet(weekDays: tracker.day ?? Set<WeekDay>())
            selectedEmoji = tracker.emoji
            selectedColor = SelectionColorStyle.fromColor(tracker.color)
        }
        
        
        
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
        
        lazy var title: UILabel = {
            let label = UILabel()
            label.text = isCreatingEvent ? "Новое событие" : "Новая привычка"
            label.textColor = UIColor.mainColorYP(.blackYP)
            label.font = FontYP.medium16
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        lazy var cancelButton = Button(type: .cancel, title: "Отменить") {
            self.dismiss(animated: true)
        }
        
        readyButton = Button(type: .primary(isActive: false), title: "Готово", tapHandler: {
            let newTracker = self.createNewTracker()
            guard let selectedCategoryID = self.selectedCategory?.id else { return }
            self.delegate?.didCreateNewTracker(newTracker: newTracker, categoryID: selectedCategoryID)
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.dismiss(animated: true, completion: nil)
            }
        })
        
        lazy var hStack: UIStackView = {
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
        
        let layouts: [Section: NSCollectionLayoutSection] = [
            .input: EditTrackerCollectionLayoutFactory.createInputLayout(),
            .list: EditTrackerCollectionLayoutFactory.createListLayout(),
            .emoji: EditTrackerCollectionLayoutFactory.createEmojiLayout(),
            .color: EditTrackerCollectionLayoutFactory.createColorLayout()
        ]
        
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            
            guard let section = Section(rawValue: sectionNumber) else {
                LogService.shared.log("Unsupported section in generateLayout", level: .error)
                return nil
            }
            return layouts[section]
        }
    }
}


// MARK: - EXTENTIONS

extension EditTrackerVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { Section.allCases.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let section = Section(rawValue: section) else {
            LogService.shared.log("Unsupported section in numberOfItemsInSection", level: .error)
            return 0
        }
        
        switch section {
        case .input: return 1
        case .list: return isCreatingEvent ? 1 : 2
        case .emoji: return K.emojis.count
        case .color: return SelectionColorStyle.allCases.count
        }
    }
    
    // Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let section = Section(rawValue: indexPath.section) else {
            LogService.shared.log("Unsupported section in cellForItemAt", level: .error)
            return .init()
        }
        
        switch section {
        case .input: return inputCell(for: indexPath, collectionView: collectionView)
        case .list: return listCell(for: indexPath, collectionView: collectionView)
        case .emoji: return emojiCell(for: indexPath, collectionView: collectionView)
        case .color: return colorCell(for: indexPath, collectionView: collectionView)
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
        
        emojiCell.emojiLabel.text = K.emojis[indexPath.row]
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
        
        guard let section = Section(rawValue: indexPath.section) else {
            LogService.shared.log("Unsupported section in viewForSupplementaryElementOfKind", level: .error)
            return header
        }
        
        switch section {
        case .input, .list: header.isHidden = true
        case .emoji: header.sectionLabel.text = "Emoji"
        case .color: header.sectionLabel.text = "Цвет"
        }
        return header
    }
}


extension EditTrackerVC: UICollectionViewDelegate {
    
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
        case 1: handleListSelection(at: indexPath)
        case 2: handleEmojiSelection(at: indexPath)
        case 3: handleColorSelection(at: indexPath)
        default: break
        }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        
    }
    
    private func handleListSelection(at indexPath: IndexPath) {
        
        let viewModel = CategoryViewModel(dependencies: dependencies)
        
        if indexPath.row == 0 {
            let vc = CategoryView(dependencies: dependencies, viewModel: viewModel)
            vc.categorySelectionDelegate = self
            present(vc, animated: true, completion: nil)
        } else if indexPath.row == 1 {
            let vc = SchedulerVC(selectedDays: Array(selectedSchedule.weekDays))
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    private func handleEmojiSelection(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell else { return }
        
        deselectCell(at: selectedEmojiIndexPath)
        
        cell.setSelected(true)
        
        selectedEmojiIndexPath = indexPath
        selectedEmoji = K.emojis[indexPath.row]
        
        isTrackerReadyToBeCreated()
    }
    
    private func handleColorSelection(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else { return }
        
        let colorIndex = indexPath.row % SelectionColorStyle.allCases.count
        let color = UIColor.selectionColorYP(SelectionColorStyle.allCases[colorIndex])
        
        cell.setSelected(true, color: color ?? .yellow)

        if let oldSelectedColorIndexPath = selectedColorIndexPath,
            let oldCell = collectionView.cellForItem(at: oldSelectedColorIndexPath) as? ColorCell {
            oldCell.setSelected(false, color: color ?? .cyan)
        }

        selectedColorIndexPath = indexPath
        selectedColor = SelectionColorStyle.allCases[indexPath.row]

        isTrackerReadyToBeCreated()
    }

    private func deselectCell(at indexPath: IndexPath?) {
        guard let indexPath = indexPath, let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        if let emojiCell = cell as? EmojiCell {
            emojiCell.setSelected(false)
        } else if let colorCell = cell as? ColorCell {
            let colorIndex = indexPath.row % SelectionColorStyle.allCases.count
            let color = UIColor.selectionColorYP(SelectionColorStyle.allCases[colorIndex])
            colorCell.setSelected(false, color: color ?? .green)
        }
    }
}

// MARK: - Add Scheduler Delegate

extension EditTrackerVC: AddSchedulerDelegate {
    
    func didUpdateSelectedDays(selectedDays: WeekDaySet) {
        self.selectedSchedule = selectedDays
        
        isTrackerReadyToBeCreated()
        
        let sectionToReload = 1
        collectionView.reloadSections(IndexSet(integer: sectionToReload))
    }
}


// MARK: - Create Tracker

extension EditTrackerVC {
    
    func isTrackerReadyToBeCreated() {
        let isScheduleValid = isCreatingEvent || !selectedSchedule.weekDays.isEmpty
        guard let title = selectedTitle, !title.isEmpty,
              selectedCategory != nil,
              selectedEmoji != nil,
              selectedColor != nil,
              isScheduleValid else {
            readyButton?.isActive = false
            return
        }
        readyButton?.isActive = true
    }
    
    func createNewTracker() -> Tracker {
        
        let title: String = selectedTitle!
        let emoji: String = selectedEmoji!
        let color: UIColor = UIColor.selectionColorYP(selectedColor!)!
        let day: Set<WeekDay>? = Set(selectedSchedule.weekDays)
        
        let newTracker = Tracker(title: title, emoji: emoji, color: color, day: day)
        
        return newTracker
    }
}

extension EditTrackerVC: CategorySelectionDelegate {
    func categorySelected(category: CategoryData) {
        selectedCategory = dependencies.сategoryStore.trackerCategory(from: category)
        let sectionToReload = 1
        collectionView.reloadSections(IndexSet(integer: sectionToReload))
    }
}


// MARK: - PROTOCOL

protocol EditTrackerVCDelegate: AnyObject {
    func didEditNewTracker(newTracker: Tracker, categoryID: UUID)
}
