import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var dependencyContainer: DependencyContainer?

    override init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.getContext()
        self.dependencyContainer = DependencyContainer(context: context)
        super.init()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let shouldShowOnboarding = UserDefaults.standard.bool(forKey: "didCompleteOnboarding")
        
        if shouldShowOnboarding {
            let homeVC = HomeVC(dependencies: dependencyContainer!)
            window.rootViewController = homeVC
        } else {
            let onboardingViewModel = OnboardingViewModel()
            let onboardingVC = OnboardingViewController(viewModel: onboardingViewModel)
            window.rootViewController = onboardingVC
        }
        
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
