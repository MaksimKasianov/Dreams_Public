//
//  AccountSettingsVC.swift
//  WeDream
//
//  Created by Kasianov on 19.10.2023.
//

import UIKit
import CoreData

class AccountSettingsVC: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bgLayer = CALayer()
        let bgImage = UIImage(named: "Background")?.cgImage
        bgLayer.frame = view.bounds
        bgLayer.contents = bgImage
        view.layer.insertSublayer(bgLayer, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let name = Shared.shared.personData?.name {
            nameLabel.text = name
        } else {
            nameLabel.text = ""
        }
        
        if let date = Shared.shared.personData?.born {
            dateLabel.text = date.formatted(dateFormat: "dd MMM yyyy")
        } else {
            dateLabel.text = ""
        }
        
        if let gender = Shared.shared.personData?.gender {
            genderLabel.text = gender
        } else {
            genderLabel.text = ""
        }
        
        if let status = Shared.shared.personData?.status {
            statusLabel.text = status
        } else {
            statusLabel.text = ""
        }
    }
    
    @IBAction func nameBt(_ sender: UIButton) {
        let yourNameVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "yourNameVC") as! YourNameVC
        yourNameVC.person = Shared.shared.personData
        show(yourNameVC, sender: self)
    }
    
    @IBAction func bornBt(_ sender: UIButton) {
        let youBornVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "youBornVC") as! YouBornVC
        youBornVC.person = Shared.shared.personData
        show(youBornVC, sender: self)
    }
    
    @IBAction func genderBt(_ sender: UIButton) {
        let yourGenderVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "yourGenderVC") as! YourGenderVC
        yourGenderVC.person = Shared.shared.personData
        show(yourGenderVC, sender: self)
    }
    
    @IBAction func statusBt(_ sender: UIButton) {
        let yourStatusVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "yourStatusVC") as! YourStatusVC
        yourStatusVC.person = Shared.shared.personData
        show(yourStatusVC, sender: self)
    }
    
    @IBAction func manageSubBt(_ sender: UIButton) {
//        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
//            if UIApplication.shared.canOpenURL(url) {
//                UIApplication.shared.open(url, options: [:])
//            }
//        }
        let manSubVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(identifier: "manageSubVC")
        show(manSubVC, sender: self)
    }
    
    
    
    @IBAction func deleteProfileBt(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete profile",
                                      message: "Are you sure you want to completely delete your profile, info, and history?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            DreamBase.shared.deleteAll()
            HelpfulBase.shared.deleteAll()
            VisitsBase.shared.deleteAll()
            MoodBase.shared.deleteAll()
            PersonBase.shared.delete()
            
            self?.dismiss(animated: true)
        }))
        
        present(alert, animated: true)
    }
}
