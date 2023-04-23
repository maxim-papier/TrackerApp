import UIKit

final class CategoryVC: UIViewController {

    private var dependencies: DependencyContainer
    private lazy var fetchedResultsController = { dependencies.fetchedResultsControllerForCategory }()

    private var selectedIndexPath: IndexPath?
    private var selectedCategoryId: UUID?

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
            print("SELECTA - \(selectedCategoryId)")
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

    // ----

    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.mainColorYP(.whiteYP)
        dependencies.trackerCategoryStore.delegate = self
        dependencies.trackerCategoryStore.setupFetchedResultsController()
        configure()
    }


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

        addCategoryButton = Button(type: .primary(isActive: true), title: "Добавить категорию") {
            [self] in
            dismiss(animated: true)
        }

        readyButton = Button(type: .primary(isActive: true), title: "Готово") {
            [self] in
            dismiss(animated: true)
        }

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


extension CategoryVC: UITableViewDelegate {}

extension CategoryVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let category = fetchedResultsController.object(at: indexPath)

        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
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

        /*
         switch (indexPath.row, weekdays.count) {
         case (firstIndex, 1): cell.buttonPosition = .single
         case (firstIndex, _): cell.buttonPosition = .first
         case (lastIndex, _): cell.buttonPosition = .last
         default: cell.buttonPosition = .middle
         }

         */


        return cell
    }

}


// MARK: - Select Cells

extension CategoryVC {

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { return true }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let previousSelectedIndexPath = selectedIndexPath {
            let previousSelectedCell = tableView.cellForRow(at: previousSelectedIndexPath) as? CategoryCell
            previousSelectedCell?.checkmarkImageView.isHidden = true
        }

        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
            selectedCategoryId = nil
            buttonToShow = .add
        } else {
            let category = fetchedResultsController.object(at: indexPath)
            selectedCategoryId = category.id

            let selectedCell = tableView.cellForRow(at: indexPath) as? CategoryCell
            selectedCell?.checkmarkImageView.isHidden = false
            selectedIndexPath = indexPath
            buttonToShow = .ready
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - Category Tracker Store Delegate

extension CategoryVC: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChangeContent() {
        self.tableView.reloadData()
    }
}
