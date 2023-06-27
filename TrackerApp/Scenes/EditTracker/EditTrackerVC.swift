import UIKit
import Combine

final class EditTrackerVC: UIViewController, UICollectionViewDelegateFlowLayout {
    
    enum Section: Int, CaseIterable {
        case input = 0
        case list
        case emoji
        case color
    }
    
    private var isCreatingEvent: Bool = false
    private var viewModel: EditTrackerViewModel
    private var cancellables = Set<AnyCancellable>()
    private var trackerID: UUID
    
    private var selectedTitle: String?
    private var selectedCategory: Category?
    private var selectedSchedule = WeekDaySet(weekDays: [])
    private var selectedEmoji: String?
    private var selectedColor: SelectionColorStyle?
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    
    weak var delegate: CreateTrackerVCDelegate?
    
    private var collection: UICollectionView! = nil
    private let listCellItemName: [String] = ["Категория", "Расписание"]
    private var readyButton: Button?
    
    private var dependencies: DependencyContainer
    
    // MARK: - UI Properties
    
    lazy var pageTitle: UILabel = {
        let label = UILabel()
        label.text = isCreatingEvent ? "Редактирование события" : "Редактирование привычки"
        label.textColor = UIColor.mainColorYP(.blackYP)
        label.font = FontYP.medium16
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var cancelButton = Button(type: .cancel, title: "Отменить") {
        self.dismiss(animated: true)
    }
    
    lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, readyButton!])
        stack.backgroundColor = .mainColorYP(.whiteYP)
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    // MARK: - Initilizers
    
    init(dependencies: DependencyContainer,
         trackerID: UUID) {
        self.dependencies = dependencies
        self.trackerID = trackerID
        self.viewModel = EditTrackerViewModel(trackerID: trackerID, dependency: dependencies)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Viewcontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainColorYP(.whiteYP)
        setupCollectionView()
        registerCells()
        setupButtons()
        setupPageLayout()
        bindViewModel()
    }
    
    private func bindViewModel() {
        
        // Tracker Title
        viewModel.$trackerTitle
            .sink { [weak self] in
                self?.selectedTitle = $0
                let titleIndexPath = IndexPath(item: 0, section: Section.list.rawValue)
                self?.collection.reloadItems(at: [titleIndexPath])
            }
            .store(in: &cancellables)
        
        // Category
        viewModel.$trackerCategory
            .sink { [weak self] newCategory in
                self?.selectedCategory = newCategory
                let categoryIndexPath = IndexPath(item: 0, section: Section.list.rawValue)
                self?.collection.reloadItems(at: [categoryIndexPath])
            }
            .store(in: &cancellables)
        
        // Schedule
        viewModel.$trackerSchedule
            .sink { [weak self] newSchedule in
                self?.selectedSchedule.weekDays = newSchedule
                let scheduleIndexPath = IndexPath(item: 1, section: Section.list.rawValue)
                self?.collection.reloadItems(at: [scheduleIndexPath])
            }
            .store(in: &cancellables)
        
        // Emoji
        viewModel.$trackerEmoji
            .sink { [weak self] newEmoji in
                guard let self = self else { return }
                self.selectedEmoji = newEmoji
                if let emojiIndex = K.emojis.firstIndex(of: newEmoji) {
                    let indexPath = IndexPath(item: emojiIndex, section: Section.emoji.rawValue)
                    self.selectedEmojiIndexPath = indexPath
                    self.collection.reloadItems(at: [indexPath])
                }
            }
            .store(in: &cancellables)
        
        // Color
        viewModel.$trackerColor
            .sink { [weak self] newColor in
                guard let self = self else { return }
                self.selectedColor = newColor
                
                if let colorIndex = SelectionColorStyle.allCases.firstIndex(of: self.selectedColor ?? .selection01) {
                    
                    let newIndexPath = IndexPath(item: colorIndex, section: Section.color.rawValue)
                    self.selectedColorIndexPath = newIndexPath
                    
                    self.handleColorSelection(at: newIndexPath)
                }
            }
            .store(in: &cancellables)
        
        // Ready button state
        viewModel.$isTrackerReady
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isReady in
                LogService.shared.log("Ready button state is \(isReady)", level: .info)
                self?.readyButton?.isActive = isReady
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup UI and Collection
    
    private func setupCollectionView() {
        collection = UICollectionView(frame: view.bounds, collectionViewLayout: generateCollectionLayout())
        collection.backgroundColor = UIColor.mainColorYP(.whiteYP)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
    }
    
    private func registerCells() {
        collection.register(Header.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: Header.identifier)
        
        let cellTypes: [UICollectionViewCell.Type] = [EmojiCell.self, ListCell.self, InputCell.self, ColorCell.self]
        cellTypes.forEach { cellType in
            collection.register(cellType, forCellWithReuseIdentifier: String(describing: cellType))
        }
    }
    
    private func setupButtons() {
        readyButton = Button(type: .primary(isActive: false), title: "Готово", tapHandler: {
            self.viewModel.saveTrackerData()
            
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.dismiss(animated: true, completion: nil)
            }
        })
    }

    private func setupPageLayout() {
        view.addSubview(collection)
        view.addSubview(pageTitle)
        view.addSubview(hStack)
        
        let vInset: CGFloat = 38
        let hInset: CGFloat = 20
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            pageTitle.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            pageTitle.topAnchor.constraint(equalTo: guide.topAnchor, constant: 27),
            
            collection.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: vInset),
            collection.bottomAnchor.constraint(equalTo: hStack.topAnchor),
            collection.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            
            hStack.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            hStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: hInset),
            hStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -hInset)
        ])
    }
    
    private func generateCollectionLayout() -> UICollectionViewLayout {
        
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
        inputCell.userInputField.text = selectedTitle
        inputCell.textFieldValueChanged = { inputText in
            self.selectedTitle = inputText
            self.viewModel.trackerTitle = inputText
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
            if selectedSchedule.weekDays.isEmpty {
                listCell.subtitleLabel.text = .none
            } else {
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
        
        if indexPath == selectedEmojiIndexPath {
            emojiCell.setSelected(true)
        } else {
            emojiCell.setSelected(false)
        }
        
        return emojiCell
    }
    
    func colorCell(for indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        let colorCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorCell.identifier,
            for: indexPath) as! ColorCell
        
        let colorIndex = indexPath.row % SelectionColorStyle.allCases.count
        let color = UIColor.selectionColorYP(SelectionColorStyle.allCases[colorIndex])
        colorCell.cellColor = color
        
        colorCell.setSelected(indexPath == selectedColorIndexPath)
        
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
        
        
        let viewModel = CategoryViewModel(dependencies: dependencies, previousSelectedCategory: selectedCategory?.id ?? .init())
        
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
        if let selectedIndexPath = selectedEmojiIndexPath,
           let previousSelectedCell = collection.cellForItem(at: selectedIndexPath) as? EmojiCell {
            previousSelectedCell.setSelected(false)
        }
        
        guard let cell = collection.cellForItem(at: indexPath) as? EmojiCell else { return }
        cell.setSelected(true)
        
        selectedEmojiIndexPath = indexPath
        selectedEmoji = K.emojis[indexPath.row]
        
        viewModel.trackerEmoji = selectedEmoji ?? "🤢"
    }
    
    private func handleColorSelection(at indexPath: IndexPath) {
        
        if let selectedIndexPath = selectedColorIndexPath,
           let previousSelectedCell = collection.cellForItem(at: selectedIndexPath) as? ColorCell {
            previousSelectedCell.setSelected(false)
        }
        
        guard let cell = collection.cellForItem(at: indexPath) as? ColorCell else { return }
        cell.setSelected(true)
        
        selectedColorIndexPath = indexPath
        selectedColor = SelectionColorStyle.allCases[indexPath.row % SelectionColorStyle.allCases.count]
    }
}

// MARK: - Selection Delegates

extension EditTrackerVC: CategorySelectionDelegate {
    func categorySelected(category: CategoryData) {
        selectedCategory = dependencies.сategoryStore.trackerCategory(from: category)
        viewModel.trackerCategory = selectedCategory
        let sectionToReload = Section.list.rawValue
        collection.reloadSections(IndexSet(integer: sectionToReload))
    }
}

extension EditTrackerVC: AddSchedulerDelegate {
    
    func didUpdateSelectedDays(selectedDays: WeekDaySet) {
        self.selectedSchedule = selectedDays
        viewModel.trackerSchedule = selectedSchedule.weekDays
        let sectionToReload = Section.list.rawValue
        collection.reloadSections(IndexSet(integer: sectionToReload))
    }
}


