import UIKit

final class NewCategoryVC: UIViewController {

    weak var delegate: NewCategoryVCDelegate?

    private var dependencies: DependencyContainer
    private lazy var fetchedResultsController = { dependencies.fetchedResultsControllerForCategory }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(InputCell.self, forCellWithReuseIdentifier: InputCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private var inputCell = InputCell()

    var onCategoryCreated: ((UUID) -> Void)?
    private var categoryName = ""


    // MARK: - Setup button

    private lazy var readyButton: Button = {
        let button = Button(type: .primary(isActive: false), title: "Готово")
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc private func readyButtonTapped() {
        let newCategory = TrackerCategory(id: UUID(), name: categoryName, trackers: [], createdAt: Date())
        let success = dependencies.trackerCategoryStore.createTrackerCategory(category: newCategory)
        if success {
            delegate?.newCategoryVC(self, didCreateNewCategoryWithId: newCategory.id)
            onCategoryCreated?(newCategory.id)
            dismiss(animated: true)
        } else {
            showErrorMessage("Такая категория уже есть")
        }
    }

    @objc private func inputFieldDidChange(_ textField: UITextField) {
        categoryName = textField.text ?? ""
        updateReadyButtonState()
    }

    private func updateReadyButtonState() {
        let isInputNotEmpty = inputCell.userInputField.text?.isEmpty == false
        readyButton.isActive = isInputNotEmpty
    }


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
        dependencies.trackerCategoryStore.setupFetchedResultsController()
        inputCell.userInputField.addTarget(self, action: #selector(inputFieldDidChange(_:)), for: .editingChanged)

        configure()
        updateReadyButtonState()
    }

    
    private func configure() {

        collectionView.delegate = self
        collectionView.dataSource = self

        let title: UILabel = {
            let label = UILabel()
            label.text = "Новая категория"
            label.textColor = UIColor.mainColorYP(.blackYP)
            label.font = FontYP.medium16
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let vInset: CGFloat = 38

        view.addSubview(collectionView)
        view.addSubview(title)
        view.addSubview(readyButton)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: vInset),
            collectionView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -24),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),

            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension NewCategoryVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        inputCell = collectionView.dequeueReusableCell(withReuseIdentifier: InputCell.identifier, for: indexPath) as! InputCell
        inputCell.userInputField.placeholder = "Введите название категории"
        inputCell.userInputField.addTarget(self, action: #selector(inputFieldDidChange(_:)), for: .editingChanged)
        return inputCell
    }
}

extension NewCategoryVC: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInset: CGFloat = 16
        let cellHeight: CGFloat = 75
        return CGSize(width: collectionView.bounds.width - 2 * horizontalInset, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

extension NewCategoryVC: UICollectionViewDelegate {

}


// MARK: - NewCategory Delegate

protocol NewCategoryVCDelegate: AnyObject {
    func newCategoryVC(_ newCategoryVC: NewCategoryVC, didCreateNewCategoryWithId categoryId: UUID)
}
