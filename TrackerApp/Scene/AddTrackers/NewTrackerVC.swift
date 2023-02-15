import UIKit

final class NewTrackerVC: UIViewController {

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

        let habitButton = ButtonType.primary(isActive: true).button(withText: "Привычка") { [weak self] in
            let vc = CreateTrackerVC()
            self?.present(vc, animated: true)
        }

        let eventButton = ButtonType.primary(isActive: true).button(withText: "Нерегулярное событие")
        eventButton.tapHandler = { }

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

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            title.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}


// MARK: - SHOW PREVIEW

import SwiftUI
struct NewTrackerVCProvider: PreviewProvider {
    static var previews: some View {
        NewTrackerVC().showPreview()
    }
}
