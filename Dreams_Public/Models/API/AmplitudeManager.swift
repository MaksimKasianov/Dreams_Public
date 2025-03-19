import AmplitudeSwift
import UIKit

final class AmplitudeManager {
    static let shared = AmplitudeManager()
    
    var amplitude: Amplitude!
    
    func instance() {
        amplitude = Amplitude(configuration: Configuration(apiKey: "", instanceName: UIDevice.current.identifierForVendor?.uuidString ?? "nil"))
    }
    
    func eventTrack(type: String, properties: [String: Any]? = nil) {
        amplitude.track(
            eventType: type,
            eventProperties: properties
        )
    }
}
