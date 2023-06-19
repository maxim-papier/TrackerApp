import UIKit

final class HomeVC: UITabBarController {


    private let dependencies: DependencyContainer
    private let onboardingPersistenceService: OnboardingPersistenceService
    
    init(dependencies: DependencyContainer,
         onboardingPersistenceService: OnboardingPersistenceService
    ) {
        self.dependencies = dependencies
        self.onboardingPersistenceService = onboardingPersistenceService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        let categoriesInBase = dependencies.trackerCategoryStore.readTrackerCategories()
        print("CORE DATA CURRENTLY CONTAINS:")
        print("---------")
        print("Categories: \(categoriesInBase.count) ")
        print("---------")
        print("Categories Names: \(categoriesInBase.map({ $0.name }))")
        print("---------")
        print("Trackers:")
        categoriesInBase.forEach {
            print($0.trackers.map { "Name — \($0.title) Schedule — \(String(describing: $0.day)) \($0.id)" }.joined(separator: "\n"))
        }
        let recordsInBase = dependencies.trackerRecordStore.fetchAllRecords()
        print("REC: \(String(describing: recordsInBase.first))")
        print("---------")
//        cleanCoreData {
//            print("All data has been cleared")
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let shouldShowOnboarding = onboardingPersistenceService.hasCompletedOnboarding()
        
        if !shouldShowOnboarding {
            let onboardingViewModel = OnboardingViewModel(onboardingPersistenceService: onboardingPersistenceService)
            let onboardingVC = OnboardingViewController(viewModel: onboardingViewModel)
            onboardingVC.modalPresentationStyle = .fullScreen
            present(onboardingVC, animated: false, completion: nil)
        }
        
    }

    // MARK: - Clear Core Data

    private func cleanCoreData(completion: @escaping() -> Void) {
        self.dependencies.trackerCategoryStore.clearCategoryData()
        self.dependencies.trackerStore.clearTrackerData()
        self.dependencies.trackerRecordStore.clearRecordData()
        completion()
    }


    // MARK: - Setup

    private func setupTabs() {
        tabBar.backgroundColor = UIColor.mainColorYP(.whiteYP)

        // Setup Tabs
        let firstVC = UINavigationController(rootViewController: TrackerVC(dependencies: dependencies))
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
