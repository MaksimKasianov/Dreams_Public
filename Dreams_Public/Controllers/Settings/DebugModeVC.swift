//
//  DebugModeVC.swift
//  WeDream
//
//  Created by Kasianov on 23.10.2023.
//

import UIKit

class DebugModeVC: UIViewController {
    @IBOutlet weak var unlimited: UISwitch!
    @IBOutlet weak var microphone: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        unlimited.isOn = Shared.shared.isDebugPremium
        microphone.isOn = Shared.shared.isMicrophone
    }
    
    @IBAction func unlimitedAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "DebugPremium")
        Shared.shared.isDebugPremium = sender.isOn
    }
    
    @IBAction func MicrophoneAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "DebugMicrophone")
        Shared.shared.isMicrophone = sender.isOn
    }
    
    @IBAction func closeBt(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func paywallBt(_ sender: UIButton) {
        let premiumVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "premiumVC")
        
        premiumVC.modalPresentationStyle = .fullScreen
        
        present(premiumVC, animated: true)
    }
    
    @IBAction func offerBt(_ sender: UIButton) {
        let offerVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "offerVC")
        
        present(offerVC, animated: true)
    }
    
    @IBAction func guestBt(_ sender: UIButton) {
        let guestVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "guestVC")
        
        present(guestVC, animated: true)
    }
}
