//
//  AdaptyManager.swift
//  WeDream
//
//  Created by Kasianov on 17.11.2023.
//

import Adapty
import UIKit

final class AdaptyManager {
    static let shared = AdaptyManager()
    var profile:  AdaptyProfile?
    
    func instance() {
        Adapty.activate("", customerUserId: UIDevice.current.identifierForVendor?.uuidString ?? "nil")
    }
    
    func checkPremium(completion: @escaping (Bool) -> Void) {
        Adapty.getProfile { result in
            if let profile = try? result.get(), profile.accessLevels["premium"]?.isActive ?? false {
                self.profile = profile
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getPaywallProducts(paywallName: String, completion: @escaping ([AdaptyPaywallProduct]?) -> Void) {
        Adapty.getPaywall(placementId: paywallName) { result in
            switch result {
            case let .success(paywall):
                Adapty.getPaywallProducts(paywall: paywall) { result in
                    switch result {
                    case let .success(products):
                        completion(products)
                    case .failure(_):
                        completion(nil)
                    }
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func makePurchase(product: AdaptyPaywallProduct, completion: @escaping (Bool) -> Void) {
        Adapty.makePurchase(product: product) { result in
            switch result {
            case let .success(info):
                if info.profile.accessLevels["premium"]?.isActive ?? false {
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(_):
                completion(false)
            }
        }
    }
    
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Adapty.restorePurchases { result in
            switch result {
            case let .success(profile):
                if profile.accessLevels["premium"]?.isActive ?? false {
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(_):
                completion(false)
            }
        }
    }
}

