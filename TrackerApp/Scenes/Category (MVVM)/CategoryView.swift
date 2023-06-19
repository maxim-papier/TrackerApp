import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func categorySelected(category: CategoryData)
}

final class CategoryView: UIViewController {
    
    private var dependencies: DependencyContainer
    private var viewModel: CategoryViewModel
    
    weak var categorySelectionDelegate: CategorySelectionDelegate?

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CategoryCellView.self, forCellReuseIdentifier: CategoryCellView.identifier)
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = UIColor.mainColorYP(.blackYP)
        label.font = FontYP.medium16
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var actionButton: Button = {
        let button = Button(
            type: .primary(isActive: true),
            title: "Добавить категорию"
        ) { [weak self] in
            self?.performButtonAction()
        }
        return button
    }()

    init(dependencies: DependencyContainer, viewModel: CategoryViewModel) {
        self.dependencies = dependencies
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.$categories.observe { [weak self] _ in
            LogService.shared.log("Categories observer triggered", level: .info)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        self.viewModel.$buttonState.observe { [weak self] state in
            LogService.shared.log("ButtonState observer triggered with state: \(state)", level: .info)
            DispatchQueue.main.async {
                switch state {
                case .add:
                    self?.actionButton.setTitle("Добавить категорию", for: .normal)
                case .ready:
                    self?.actionButton.setTitle("Готово", for: .normal)
                }
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Viecontroller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchCategories()
        view.backgroundColor = UIColor.mainColorYP(.whiteYP)
        configureLayout()
    }
    
    private func configureLayout() {
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(actionButton)

        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 27),
            
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: 24),
            
            actionButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func performButtonAction() {
        if viewModel.buttonState == .add {
            let vc = NewCategoryVC(dependencies: dependencies)
            vc.delegate = self
            present(vc, animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

// MARK: - Delegate Methods

// TableView Datasource
extension CategoryView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCellView.identifier, for: indexPath) as? CategoryCellView,
              let viewModel = viewModel.cellViewModel(at: indexPath) else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configure(with: viewModel)
        return cell
    }
}

// TableView Delegate
extension CategoryView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath)
        
        if let selectedCategory = viewModel.selectedCategory {
            categorySelectionDelegate?.categorySelected(category: selectedCategory)
        }
        tableView.reloadData()
    }
}

// New Category Delegate
extension CategoryView: NewCategoryDelegate {
    func newCategoryController(_ newCategoryVC: NewCategoryVC, didCreateNewCategoryWithId categoryId: UUID) {
        viewModel.fetchCategories()
        viewModel.selectCategory(withId: categoryId)
        
        if let selectedCategory = viewModel.selectedCategory {
            categorySelectionDelegate?.categorySelected(category: selectedCategory)
        }
        tableView.reloadData()
    }
}
