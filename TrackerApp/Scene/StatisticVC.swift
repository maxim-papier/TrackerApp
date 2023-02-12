import UIKit

class StatisticVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        view.backgroundColor = .colorYP(.whiteYP)
        setupNavBar()
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
        TrackerVC().showPreview()
    }
}
