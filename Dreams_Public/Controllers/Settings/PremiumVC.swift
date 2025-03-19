//
//  PremiumVC.swift
//  DreamApp
//
//  Created by Kasianov on 13.02.2024.
//

import UIKit
import Adapty

class PremiumVC: UIViewController {

    @IBOutlet weak var weekPattern: GradientImage!
    @IBOutlet weak var monthPattern: GradientImage!
    @IBOutlet weak var yearPattern: GradientImage!
    
    @IBOutlet weak var weakView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var yearView: UIView!
    
    @IBOutlet weak var weeklyPrice: UILabel!
    @IBOutlet weak var monthlyPrice: UILabel!
    @IBOutlet weak var annualPrice: UILabel!
    
    @IBOutlet weak var weekLoader: UIActivityIndicatorView!
    @IBOutlet weak var monthLoader: UIActivityIndicatorView!
    @IBOutlet weak var yearLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var continueBt: UIButton!
    
    var overlayView: UIView!
    
    private var products: [AdaptyPaywallProduct]?
    var selected: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weeklyPrice.isHidden = true
        monthlyPrice.isHidden = true
        annualPrice.isHidden = true
        
        continueBt.isEnabled = false
        
        AdaptyManager.shared.getPaywallProducts(paywallName: "Premium", completion: { products in
            if let products = products {
                DispatchQueue.main.async { [self] in
                    self.products = products
                    
                    let symbol = products[0].currencySymbol ?? ""
                    
                    weeklyPrice.text = "\(symbol)" + "\(products[0].price)"
                    monthlyPrice.text = "\(symbol)" + "\(products[1].price)"
                    annualPrice.text = "\(symbol)" + "\(products[2].price)"
                    
                    weekLoader.isHidden = true
                    monthLoader.isHidden = true
                    yearLoader.isHidden = true
                    
                    weeklyPrice.isHidden = false
                    monthlyPrice.isHidden = false
                    annualPrice.isHidden = false
                    
                    continueBt.isEnabled = true
                    
                    setupUI(tag: selected)
                }
            }
        })
    }

    @IBAction func closeBt(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func selectBt(_ sender: UIButton) {
        selected = sender.tag
        setupUI(tag: selected)
    }
    
    func setupUI(tag: Int) {
        let buttons = [
            ["view": weakView, "price": weeklyPrice, "pattern": weekPattern],
            ["view": monthView, "price": monthlyPrice, "pattern": monthPattern],
            ["view": yearView, "price": annualPrice, "pattern": yearPattern]
        ]
        
        for i in 0..<buttons.count {
            if let view = buttons[i]["view"] as? UIView,
               let price = buttons[i]["price"] as? UILabel,
               let pattern = buttons[i]["pattern"] as? GradientImage {
                
                UIView.animate(withDuration: 0.25, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent]) {
                    if i == tag {
                        pattern.tintColor = Colors.primary_100
                        pattern.endColor = Colors.primary_50
                        
                        view.backgroundColor = Colors.primary_50
                        view.layer.borderColor = Colors.primary_500.cgColor
                        price.textColor = Colors.primary_500
                    } else {
                        pattern.tintColor = Colors.surface_500
                        pattern.endColor = Colors.surface_100
                        
                        view.backgroundColor = Colors.surface_100
                        view.layer.borderColor = Colors.surface_50.cgColor
                        price.textColor = Colors.shades_gray_800
                    }
                }
            }
        }
    }
    
    @IBAction func continueBt(_ sender: UIButton) {
        if let product = products?[selected] {
            showOverlay()
            
            AdaptyManager.shared.makePurchase(product: product, completion: { premium in
                DispatchQueue.main.async {
                    Shared.shared.isPremium = premium
                    if premium {
                        self.dismiss(animated: true)
                    } else {
                        self.hideOverlay()
                    }
                }
            })
        }
    }
    
    @IBAction func restoreBt(_ sender: UIButton) {
        showOverlay()
        AdaptyManager.shared.restorePurchases(completion: { premium in
            DispatchQueue.main.async {
                if premium == true {
                    Shared.shared.isPremium = premium
                    self.dismiss(animated: true)
                } else {
                    self.alertRestoreError()
                }
                self.hideOverlay()
            }
        })
    }
    
    func showOverlay() {
        overlayView = UIView(frame: view.frame)
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        overlayView.makeToastActivity(.center)
        
        view.addSubview(overlayView)
    }
    
    func hideOverlay() {
        overlayView.hideToastActivity()
        overlayView.removeFromSuperview()
        overlayView = nil
    }
    
    @IBAction func privacyBt(_ sender: UIButton) {
        let webView = WebViewVC(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Privacy policy", ofType: "pdf")!))
        let navVC = UINavigationController(rootViewController: webView)
        present(navVC, animated: true)
    }
    
    @IBAction func eulaBt(_ sender: UIButton) {
        let webView = WebViewVC(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Terms of service", ofType: "pdf")!))
        let navVC = UINavigationController(rootViewController: webView)
        present(navVC, animated: true)
    }
}

extension UIViewController {
    func alertRestoreError() {
        let alert = UIAlertController(title: "Restore Error",
                                      message: "There are no purchases to restore.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: { _ in
        }))
        self.present(alert, animated: true)
    }
}
