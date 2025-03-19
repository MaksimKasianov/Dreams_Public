//
//  SplashVC.swift
//  WeDream
//
//  Created by Kasianov on 11.10.2023.
//

import UIKit
import AVFAudio
import CoreData

class SplashVC: UIViewController {
    
    @IBOutlet weak var logoStack: UIStackView!
    
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let container: NSPersistentCloudKitContainer = appDelegate.persistentContainer
        
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { (notification) in
            container.viewContext.perform {
                container.viewContext.mergeChanges(fromContextDidSave: notification)
            }
        }
        
        DreamSearch.shared.decodePlist()
        
        FirebaseImageLoader.shared.listFilesInStorage(path: "Dreams/") { list in
            DreamSearch.shared.decodeSorted(sortOrder: list)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for child in logoStack.arrangedSubviews {
            child.alpha = 0
            child.transform = CGAffineTransform(translationX: 0, y: child.frame.size.height)
        }
        
        AdaptyManager.shared.checkPremium(completion: { isPremium in
            print("Premium: \(isPremium)")
            Shared.shared.isPremium = isPremium
            
            if Shared.shared.isDebugPremium {
                Shared.shared.isPremium = true
            }
            
            self.animateLoad()
        })
    }
    
    func animateLoad() {
        
        DispatchQueue.main.async() { [self] in
            if let audioPath = Bundle.main.path(forResource: "wedream_logo_quiet", ofType: "wav") {
                let audioURL = URL(fileURLWithPath: audioPath)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                    audioPlayer?.volume = 0.33
                    
                    audioPlayer!.play()
                } catch {
                    print("Ошибка при инициализации аудиоплеера: \(error)")
                }
            } else {
                print("Аудиофайл не найден")
            }
            
            for (i, child) in logoStack.arrangedSubviews.enumerated() {
                UIView.animate(withDuration: 0.25, delay: 0.04 * Double(i), options: [.curveEaseInOut], animations: {
                    child.transform = CGAffineTransform.identity
                    child.alpha = 1.0
                })
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            PersonBase.shared.loadPerson() { result in
                if result != nil {
                    Shared.shared.personData = result
                    
                    let mainTabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainTabBar")
                    mainTabBar.modalPresentationStyle = .fullScreen
                    mainTabBar.modalTransitionStyle = .crossDissolve
                    
                    self.present(mainTabBar, animated: true)
                } else {
                    let registrationNC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "registrationNC")
                    registrationNC.modalPresentationStyle = .fullScreen
                    registrationNC.modalTransitionStyle = .crossDissolve
                    
                    self.present(registrationNC, animated: true)
                }
            }
        }
    }
    
    private func isFirstLaunch() -> Bool {
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        return !isFirstLaunch
    }
}
