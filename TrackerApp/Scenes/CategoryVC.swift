import UIKit

final class CategoryVC: UIViewController {

    weak var delegate: CategorySelectionDelegate?

    private var dependencies: DependencyContainer
    private lazy var fetchedResultsController = { dependencies.fetchedResultsControllerForCategory }()

    private var selectedIndexPath: IndexPath?
    private var selectedCategoryId: UUID?
    private var selectedCategory: TrackerCategory?

    private let tableView: UITableView = {
        let table = UITableView()
        table.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        table.layer.masksToBounds = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()


    // MARK: - Set Buttons

    private enum ButtonToShow { case add, ready }

    private var buttonToShow: ButtonToShow = .add {
        didSet {
            updateButton()
        }
    }

    private var addCategoryButton = UIButton()
    private var readyButton = UIButton()

    private func updateButton() {
        switch buttonToShow {
        case .add:
            addCategoryButton.isHidden = false
            readyButton.isHidden = true
        case .ready:
            addCategoryButton.isHidden = true
            readyButton.isHidden = false
        }
    }

    @objc func doneButtonTapped() {
        if let selectedCategory = selectedCategory {
            delegate?.categorySelected(category: selectedCategory)
        }
        dismiss(animated: true, completion: nil)
    }


    // MARK: - Initilizers

    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.mainColorYP(.whiteYP)
        dependencies.trackerCategoryStore.delegate = self
        dependencies.trackerCategoryStore.setupFetchedResultsController()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedCategoryId = selectedCategoryId,
           let selectedCategoryIndex = fetchedResultsController.fetchedObjects?.firstIndex(where: { $0.id == selectedCategoryId }) {
            let indexPath = IndexPath(row: selectedCategoryIndex, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
    }


    // MARK: - Configuration

    private func configure() {

        tableView.delegate = self
        tableView.dataSource = self

        let title: UILabel = {
            let label = UILabel()
            label.text = "Категория"
            label.textColor = UIColor.mainColorYP(.blackYP)
            label.font = FontYP.medium16
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        addCategoryButton = Button(type: .primary(isActive: true), title: "Добавить категорию") { [weak self] in
            guard let self else { return }

            let vc = NewCategoryVC(dependencies: self.dependencies)
            vc.delegate = self
            self.present(vc, animated: true)

            //self.navigationController?.pushViewController(vc, animated: true)
        }

        readyButton = Button(type: .primary(isActive: true), title: "Готово") { [weak self] in
            guard let self else { return }
            dismiss(animated: true)
        }

        readyButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)

        view.addSubview(title)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
        view.addSubview(readyButton)

        updateButton()

        let vInset: CGFloat = 38

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),

            tableView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: vInset),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
            tableView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}


extension CategoryVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let category = fetchedResultsController.object(at: indexPath)

        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
        cell.labelMenu.text = category.name
        cell.checkmarkImageView.isHidden = indexPath != selectedIndexPath

        let numberOfCategories = fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0
        let firstIndex = 0
        let lastIndex = numberOfCategories - 1

        switch (indexPath.row, numberOfCategories) {
        case (firstIndex, 1): cell.buttonPosition = .single
        case (firstIndex, _): cell.buttonPosition = .first
        case (lastIndex, _): cell.buttonPosition = .last
        default: cell.buttonPosition = .middle
        }

        return cell
    }
}

extension CategoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        guard let cell = cell as? CategoryCell else { return }

        let numberOfCategories = fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0

        let firstIndex = 0
        let lastIndex = numberOfCategories - 1

        switch (indexPath.row, numberOfCategories) {
        case (firstIndex, 1): cell.buttonPosition = .single
        case (firstIndex, _): cell.buttonPosition = .first
        case (lastIndex, _): cell.buttonPosition = .last
        default: cell.buttonPosition = .middle
        }
    }
}



// MARK: - Select Cells

extension CategoryVC {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return true }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let categoryStore = dependencies.trackerCategoryStore
        let categoryData = fetchedResultsController.object(at: indexPath)

        if let previousIndexPath = selectedIndexPath,
           let previousCell = tableView.cellForRow(at: previousIndexPath) as? CategoryCell {
            previousCell.checkmarkImageView.isHidden = true
        }

        if indexPath == selectedIndexPath {
            tableView.deselectRow(at: indexPath, animated: true)
            selectedIndexPath = nil
            selectedCategory = nil
            buttonToShow = .add
        } else {
            selectedIndexPath = indexPath
            selectedCategory = categoryStore.trackerCategory(from: categoryData)
            buttonToShow = .ready

            if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
                cell.checkmarkImageView.isHidden = false
            }
        }
    }
}


// MARK: - Category Tracker Store Delegate

extension CategoryVC: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChangeContent() {
        self.tableView.reloadData()
    }
}


// MARK: - New Category Delegate

extension CategoryVC: NewCategoryVCDelegate {

    private func presentNewCategoryVC() {

        let newCategoryVC = NewCategoryVC(dependencies: dependencies)
        newCategoryVC.delegate = self
        newCategoryVC.onCategoryCreated = { [weak self] categoryId in
            self?.selectedCategoryId = categoryId
        }

        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        present(navigationController, animated: true, completion: nil)
    }

    func newCategoryVC(_ controller: NewCategoryVC, didCreateNewCategoryWithId id: UUID) {

        if let category = fetchedResultsController.fetchedObjects?.first(where: { $0.id == id }),
           let indexPath = fetchedResultsController.indexPath(forObject: category) {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        }
    }
}
