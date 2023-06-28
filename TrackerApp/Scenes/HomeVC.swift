import UIKit

final class HomeVC: UITabBarController {


    private let dependencies: DependencyContainer
    private let onboardingPersistenceService: OnboardingPersistenceService
    private let localization = LocalizationService()
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let shouldShowOnboarding = onboardingPersistenceService.hasCompletedOnboarding()
        
        if !shouldShowOnboarding {
            let onboardingViewModel = OnboardingViewModel(onboardingPersistenceService: onboardingPersistenceService)
            let onboardingVC = OnboardingView(viewModel: onboardingViewModel)
            onboardingVC.modalPresentationStyle = .fullScreen
            present(onboardingVC, animated: false, completion: nil)
        }
    }

    // MARK: - Setup

    private func setupTabs() {
        tabBar.backgroundColor = UIColor.mainColorYP(.whiteYP)

        // Setup Tabs
        let firstVC = UINavigationController(rootViewController: TrackersVC(dependencies: dependencies, analytic: YandexMetricaService(), pinSevice: PinService(stores: dependencies)))
        let secondVC = UINavigationController(rootViewController: StatisticVC())
        let controllers = [firstVC, secondVC]
        viewControllers = controllers

        // Titles Style
        let font = FontYP.medium10
        let textAttributes = [NSAttributedString.Key.font: font]

        firstVC.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
        firstVC.tabBarItem = UITabBarItem(
            title: localization.localized(
                "tabbar.trackers.title",
                comment: "Tabbar Tracker Tab"),
            image: UIImage(named: "trackersIcon28x28"),
            selectedImage: nil
        )

        secondVC.tabBarItem.setTitleTextAttributes(textAttributes, for: .normal)
        secondVC.tabBarItem = UITabBarItem(
            title: localization.localized(
                "tabbar.statistic.title",
                comment: "Tabbar Tracker Tab"),
            image: UIImage(named: "statisticIcon28x28"),
            selectedImage: nil)

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
