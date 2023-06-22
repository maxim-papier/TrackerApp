import UIKit

final class TrackerOrEventVC: UIViewController {

    var trackerVC: TrackersVC?

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
        setup()
    }

    private func setup() {

        let title: UILabel = {
            let label = UILabel()
            label.text = "Создание трекера"
            label.textColor = UIColor.mainColorYP(.blackYP)
            label.font = FontYP.medium16
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        let habitButton = Button(type: .primary(isActive: true), title: "Привычка") { [weak self] in
            guard let self = self else { return }

            let vc = CreateTrackerVC(dependencies: self.dependencies)
            vc.isCreatingEvent = false
            vc.delegate = self.trackerVC

            self.present(vc, animated: true)
        }

        let eventButton = Button(type: .primary(isActive: true), title: "Нерегулярное событие") { [weak self] in
            guard let self = self else { return }

            let vc = CreateTrackerVC(dependencies: self.dependencies)
            vc.isCreatingEvent = true
            vc.delegate = self.trackerVC

            present(vc, animated: true, completion: nil)
        }

        let vStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 8
            stack.translatesAutoresizingMaskIntoConstraints = false
            return stack
        }()

        view.backgroundColor = .mainColorYP(.whiteYP)
        view.addSubview(title)
        view.addSubview(vStack)
        vStack.addArrangedSubview(habitButton)
        vStack.addArrangedSubview(eventButton)

        let hInset: CGFloat = 16

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: hInset),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -hInset),
            vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
