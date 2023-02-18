import UIKit

final class TrackerOrEventVC: UIViewController {

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
            let vc = CreateTrackerVC()
            self?.present(vc, animated: true)
        }

        let eventButton = Button(type: .primary(isActive: true), title: "Нерегулярное событие") { [weak self] in
            self?.dismiss(animated: true)
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


// MARK: - SHOW PREVIEW

import SwiftUI
struct NewTrackerVCProvider: PreviewProvider {
    static var previews: some View {
        TrackerOrEventVC().showPreview()
    }
}
