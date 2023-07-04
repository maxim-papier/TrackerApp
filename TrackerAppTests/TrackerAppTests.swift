import XCTest
import SnapshotTesting
@testable import TrackerApp

final class TrackerTests: XCTestCase {
    
    func testTrackersViewControllerLight() {
        
        //isRecording = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.getContext()
        let stores = DependencyContainer(context: context)
        let pinService = PinService(stores: stores)
        
        let vc = UINavigationController(
            rootViewController: TrackersVC(dependencies: stores, analytic: YandexMetricaService(), pinSevice: pinService)
        )

        assertSnapshots(matching: vc, as: [.image(traits: .init(userInterfaceStyle: .light))])
    }

    func testTrackersViewControllerDark() {
        
        //isRecording = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.getContext()
        let stores = DependencyContainer(context: context)
        let pinService = PinService(stores: stores)

        let vc = UINavigationController(
            rootViewController: TrackersVC(dependencies: stores, analytic: YandexMetricaService(), pinSevice: pinService)
        )

        assertSnapshots(matching: vc, as: [.image(traits: .init(userInterfaceStyle: .dark))])
    }
}
