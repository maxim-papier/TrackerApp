import Foundation
import YandexMobileMetrica


final class YandexMetricaService {
    func log(event: Event) {
        YMMYandexMetrica.reportEvent("EVENT", parameters: paramsFor(event), onFailure: { error in
            LogService.shared.log(
                "Report error: \(error.localizedDescription)",
                level: .error
            )
        })
    }
}

private extension YandexMetricaService {
    private func paramsFor(_ event: Event) -> [String: String] {
        switch event {
        case let .open(scene), let .close(scene):
            let openClose = ["event": event.eventName, "screen": scene.rawValue]
            return openClose
        case let .click(scene, item):
            let click = ["event": event.eventName, "screen": scene.rawValue, "item": item]
            LogService.shared.log("\(click)", level: .info)
            return click
        }
    }
}
