//
//  OfferVC.swift
//  DreamApp
//
//  Created by Kasianov on 14.02.2024.
//

import UIKit
import Adapty

class OfferVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var newPrice: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var continueBt: UIButton!
    @IBOutlet weak var oldLoader: UIActivityIndicatorView!
    @IBOutlet weak var newLoader: UIActivityIndicatorView!
    
    private var products: [AdaptyPaywallProduct]?
    
    var overlayView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributedString = NSMutableAttributedString(string: titleLabel.text ?? "")
        
        attributedString.setColorForText(textToFind: "33%", withColor: UIColor(hexString: "E83768"))
        
        titleLabel.attributedText = attributedString
        
        AdaptyManager.shared.getPaywallProducts(paywallName: "Offer33", completion: { products in
            if let products = products {
                DispatchQueue.main.async { [self] in
                    self.products = products
                    
                    let symbol = products.first?.currencySymbol ?? ""
                    
                    let oldPriceStr = products[0].price
                    
                    let oldAttributed = NSMutableAttributedString(string: "\(symbol)\(oldPriceStr)")
                    
                    oldAttributed.addAttribute(.strikethroughStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSRange(location: 0, length: oldAttributed.length))
                    
                    oldPrice.attributedText = oldAttributed
                    
                    let newPriceStr = products[1].price
                    newPrice.text = "\(symbol)\(newPriceStr)"
                    
                    oldLoader.stopAnimating()
                    newLoader.stopAnimating()
                }
            }
        })
    }
    
    @IBAction func continueBt(_ sender: UIButton) {
        if let product = products?[1] {
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
    
    @IBAction func closeBt(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
