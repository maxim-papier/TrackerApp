import UIKit

class HomeVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabsSetup()
    }

    func tabsSetup() {
        tabBar.backgroundColor = .colorYP(.whiteYP)

        // Setup Tabs
        let firstVC = UINavigationController(rootViewController: TrackerVC())
        let secondVC = StatisticVC()

        self.viewControllers = [firstVC, secondVC]

        // Titles Style
        let font = FontYP.medium10
        let textAttributes = [NSAttributedString.Key.font: font]

        firstVC.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
        firstVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "trackersIcon28x28"), selectedImage: nil)

        secondVC.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
        secondVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statisticIcon28x28"), selectedImage: nil)

        // Cast shadow
        self.tabBar.layer.shadowColor = UIColor.black.cgColor
        self.tabBar.layer.shadowOpacity = 0.3
        self.tabBar.layer.shadowOffset = .init(width: 0, height: -0.5)
    self.tabBar.layer.masksToBounds = false

        prepare(firstVC)
    }
}

extension HomeVC {

    func prepare(_ navigationController: UINavigationController) {
        navigationController.navigationBar.prefersLargeTitles = true

    }
}



// MARK: - SHOW PREVIEW

import SwiftUI
struct HomeVCProvider: PreviewProvider {
    static var previews: some View {
        HomeVC().showPreview()
    }
}
