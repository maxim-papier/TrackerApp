import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool { return true }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)

        if let sceneDelegate = connectingSceneSession.scene?.delegate as? SceneDelegate {
            sceneDelegate.dependencyContainer = DependencyContainer(context: getContext())
        }

        return sceneConfiguration

    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}


    // MARK: - Core Data

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerDataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    func saveData() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let errorNS = error as NSError
                fatalError("Unresolved error \(errorNS), \(errorNS.userInfo)")
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) { saveData() }
    func applicationDidEnterBackground(_ application: UIApplication) { saveData() }
    
    func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}


