import UIKit

final class CategoryAddVC: UIViewController {


    private var dependencies: DependencyContainer
    private lazy var fetchedResultsController = { dependencies.fetchedResultsControllerForCategory }()

    let tableView: UITableView = {
        let table = UITableView()
        table.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        table.layer.masksToBounds = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
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

        let addCategoryButton = Button(type: .primary(isActive: true), title: "Готово") {
            [self] in
            dismiss(animated: true)
        }

        view.addSubview(title)
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)

        let vInset: CGFloat = 38

        NSLayoutConstraint.activate([

            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),

            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

