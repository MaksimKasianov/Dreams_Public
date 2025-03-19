//
//  AppDelegate.swift
//  WeDream
//
//  Created by Kasianov on 24.07.2023.
//

import UIKit
import CoreData
import FirebaseCore
import Sentry
import AppTrackingTransparency
import AppsFlyerLib
import AVFoundation
import AppLovinSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        SentrySDK.start { options in
            options.dsn = ""
            options.tracesSampleRate = 1.0
            
        }
        
        AdaptyManager.shared.instance()
        AmplitudeManager.shared.instance()
        
        //MARK: AppsFlyer
        AppsFlyerLib.shared().appsFlyerDevKey = ""
        AppsFlyerLib.shared().appleAppID = ""
        
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        AppsFlyerLib.shared().delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error.localizedDescription)
        }
        
        let initConfig = ALSdkInitializationConfiguration(sdkKey: "") { builder in
            builder.mediationProvider = ALMediationProviderMAX
//             Enable test mode by default for the current device.
//            if let currentIDFV = UIDevice.current.identifierForVendor?.uuidString
//            {
//                builder.testDeviceAdvertisingIdentifiers = [currentIDFV]
//            }
        }
        
        // Initialize the SDK with the configuration
        ALSdk.shared().initialize(with: initConfig) { sdkConfig in
            // Start loading ads
        }
        
        return true
    }

    @objc func didBecomeActiveNotification() {
        AppsFlyerLib.shared().start()
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        print("AuthorizationSatus is authorized")
                    case .denied, .notDetermined, .restricted:
                        break
                    @unknown default:
                        fatalError("Invalid authorization status")
                    }
                }
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "DreamApp")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
//      //if(!NSUbiquitousKeyValueStore.default.bool(forKey: "icloud_sync")){
//        if !UserDefaults.standard.bool(forKey: "icloud_sync") {
//            description.cloudKitContainerOptions = nil
//        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    } ()
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: AppsFlyerLibDelegate {

    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        
        //Adapty.updateAttribution(data, source: .appsflyer, networkUserId: AppsFlyerLib.shared().getAppsFlyerUID())
    }
    
    func onConversionDataFail(_ error: Error) {
        print("\(error)")
    }
}
