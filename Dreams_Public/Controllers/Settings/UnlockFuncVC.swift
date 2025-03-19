//
//  AdOrPremiumVC.swift
//  Gia
//
//  Created by Kasianov on 25.10.2024.
//

import UIKit
import AppLovinSDK

class UnlockFuncVC: UIViewController {
    
    var unlockedFunc: UnlockedFunctions = .sound
    
    var rewardedAd: MARewardedAd!
    var retryAttempt = 0.0
    
    weak var delegate: UnlockDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rewardedAd = MARewardedAd.shared(withAdUnitIdentifier: "59f4e7812315a1fa")
        rewardedAd.delegate = self
        
        // Load the first ad
        rewardedAd.load()
    }
    
    @IBAction func closeBt(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func showPremiumBt(_ sender: UIButton) {
        dismiss(animated: true)
        
        delegate?.showPremium()
    }
    
    @IBAction func showRewardedAd(_ sender: UIButton) {
        let overlayView = UIView(frame: view.frame)
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            
        overlayView.makeToastActivity(.center)
        view.addSubview(overlayView)
        
        if rewardedAd.isReady {
            rewardedAd.show()
        } else {
            retryAttempt += 1
        }
    }
}
    // MARK: MAAdDelegate Protocol
extension UnlockFuncVC: MARewardedAdDelegate {
    func didLoad(_ ad: MAAd)
    {
        // Rewarded ad is ready to show. '[self.rewardedAd isReady]' now returns 'YES'.
        
        // Reset retry attempt
        retryAttempt = 0
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError)
    {
        // Rewarded ad failed to load
        // AppLovin recommends that you retry with exponentially higher delays up to a maximum delay (in this case 64 seconds).
        
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, retryAttempt))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
            self.rewardedAd.load()
        }
    }
    
    func didDisplay(_ ad: MAAd) {}
    
    func didClick(_ ad: MAAd) {}
    
    func didHide(_ ad: MAAd)
    {
        // Rewarded ad is hidden. Pre-load the next ad
        rewardedAd.load()
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError)
    {
        // Rewarded ad failed to display. AppLovin recommends that you load the next ad.
        rewardedAd.load()
    }
    
    // MARK: MARewardedAdDelegate Protocol
    
    func didRewardUser(for ad: MAAd, with reward: MAReward)
    {
        self.dismiss(animated: true)
            
        self.delegate?.unlockFunc(unfunc: unlockedFunc)
    }
}

protocol UnlockDelegate: AnyObject {
    func unlockFunc(unfunc: UnlockedFunctions)
    func showPremium()
}


enum UnlockedFunctions {
    case createPicture
    case reviewDream
    case sound
}
