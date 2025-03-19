//
//  ManageSubscriptionVC.swift
//  DreamApp
//
//  Created by Kasianov on 22.04.2024.
//

import UIKit
import Adapty

class ManageSubscriptionVC: UIViewController {

    @IBOutlet weak var subscriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var getPremiumBt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let profile = AdaptyManager.shared.profile {
            self.subscriptionLabel.text = "Premium"
            
            self.statusLabel.text = "Active"
            
            if let date = profile.accessLevels["premium"]?.expiresAt {
                self.dateView.isHidden = false
                self.dateLabel.text = date.formatted(dateFormat: "d MMMM yyyy")
                self.dateView.isHidden = false
            } else {
                self.dateView.isHidden = true
            }
            getPremiumBt.isHidden = true
            
        } else {
            self.subscriptionLabel.text = "Free"
            self.statusLabel.text = "Not active"
            
            self.dateView.isHidden = true
            getPremiumBt.isHidden = false
        }
    }
    
    @IBAction func getPremiumBt(_ sender: UIButton) {
        self.showPremiumVC()
    }
}
