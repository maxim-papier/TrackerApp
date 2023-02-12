import UIKit

class StatisticVC: UIViewController {

    let placeholder = PlaceholderType.noCategories.placeholder

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.backgroundColor = .colorYP(.whiteYP)
        setupNavBar()
        view.addSubview(placeholder)

        placeholder.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            placeholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholder.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavBar() {
        let title = "Статистика"
        navigationItem.title = title
    }
}


// MARK: - SHOW PREVIEW

import SwiftUI
struct StatisticVCProvider: PreviewProvider {
    static var previews: some View {
        StatisticVC().showPreview()
    }
}
