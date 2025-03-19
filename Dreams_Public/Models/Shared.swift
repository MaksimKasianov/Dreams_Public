import Foundation
import AVFoundation
 
final class Shared {
    static let shared = Shared()
    let apiKey: String = ""
    var isPremium: Bool = false
    
    var registerData = PersonRegister()
    
    var personData: PersonData?
    var nameApp = "WeDream"
    func getVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "\(nameApp) v\(appVersion)"
        } else {
            return ""
        }
    }
    
    //MARK: - Debug
    var isDebugPremium: Bool = UserDefaults.standard.bool(forKey: "DebugPremium")
    var isMicrophone: Bool = UserDefaults.standard.bool(forKey: "DebugMicrophone")
}



