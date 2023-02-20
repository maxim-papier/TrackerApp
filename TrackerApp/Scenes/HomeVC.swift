import UIKit

final class HomeVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        tabBar.backgroundColor = UIColor.mainColorYP(.whiteYP)

        // Setup Tabs
        let firstVC = UINavigationController(rootViewController: TrackerVC())
        let secondVC = UINavigationController(rootViewController: StatisticVC())
        let controllers = [firstVC, secondVC]
        viewControllers = controllers

        // Titles Style
        let font = FontYP.medium10
        let textAttributes = [NSAttributedString.Key.font: font]

        firstVC.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
        firstVC.tabBarItem = UITabBarItem(title: "Trackers", image: UIImage(named: "trackersIcon28x28"), selectedImage: nil)

        secondVC.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
        secondVC.tabBarItem = UITabBarItem(title: "Statistics", image: UIImage(named: "statisticIcon28x28"), selectedImage: nil)

        // Cast shadow
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = .init(width: 0, height: -0.5)
        tabBar.layer.masksToBounds = false

        controllers.forEach(prepare)
    }
}

extension HomeVC {
    private func prepare(_ navigationController: UINavigationController) {
        navigationController.navigationBar.prefersLargeTitles = true

        let font = FontYP.bold34
        let textAttributes = [NSAttributedString.Key.font: font]

        navigationController.navigationBar.standardAppearance.largeTitleTextAttributes = textAttributes
    }
}

// MARK: - SHOW PREVIEW

import SwiftUI
struct HomeVCProvider: PreviewProvider {
    static var previews: some View {
        HomeVC().showPreview()
    }
}
