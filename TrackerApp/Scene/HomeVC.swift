import UIKit

class HomeVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabsSetup()
    }


    func tabsSetup() {

        // Setup Tabs
        let firstVC = TrackerVC()
        let secondVC = StatisticVC()
        self.viewControllers = [firstVC, secondVC]

        tabBar.backgroundColor = .colorYP(.whiteYP)

        // Cast shadow
        self.tabBar.layer.shadowColor = UIColor.black.cgColor
        self.tabBar.layer.shadowOpacity = 0.3
        self.tabBar.layer.shadowOffset = .init(width: 0, height: -0.5)
        self.tabBar.layer.masksToBounds = false

        // Titles Style
        let font = FontYP.medium10
        let textAttributes = [NSAttributedString.Key.font: font]

        firstVC.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
        firstVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "trackersIcon28x28"), selectedImage: nil)

        secondVC.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
        secondVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "statisticIcon28x28"), selectedImage: nil)


    }
}


// MARK: - SHOW PREVIEW

import SwiftUI
struct HomeVCProvider: PreviewProvider {
    static var previews: some View {
        HomeVC().showPreview()
    }
}
