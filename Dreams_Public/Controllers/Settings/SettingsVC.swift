//
//  SettingsVC.swift
//  WeDream
//
//  Created by Kasianov on 19.10.2023.
//

import UIKit
import MessageUI
import Toast

class SettingsVC: UIViewController {

    @IBOutlet weak var versionBt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionBt.setTitle(Shared.shared.getVersion(), for: .normal)
        
        let bgLayer = CALayer()
        let bgImage = UIImage(named: "Background")?.cgImage
        bgLayer.frame = view.bounds
        bgLayer.contents = bgImage
        bgLayer.contentsGravity = .resizeAspectFill
        
        view.layer.insertSublayer(bgLayer, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
    }
    
    @IBAction func versionBt(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Debug Mode", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let submitAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
            if let text = alertController?.textFields?.first?.text, text == "xplaixplai" {
                let debugModeVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "debugModeVC")
                debugModeVC.modalPresentationStyle = .overFullScreen
                self.present(debugModeVC, animated: true)
            } else {
                self.view.makeToast("Error", position: .center)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func accountBt(_ sender: UIButton) {
        let accountSettingsVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "accountSettingsVC")
        show(accountSettingsVC, sender: self)
    }
    
    @IBAction func privacyBt(_ sender: UIButton) {
        let vc = WebViewVC(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Privacy policy", ofType: "pdf")!))
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    @IBAction func termsBt(_ sender: UIButton) {
        let vc = WebViewVC(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Terms of service", ofType: "pdf")!))
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    @IBAction func contactSupportBt(_ sender: UIButton) {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["support@xplai.com"])
        composer.setSubject("\(Shared.shared.nameApp) Support")
        composer.setMessageBody("\n\n\n\n\n\n\n\n\n\n\(Shared.shared.getVersion())\nUser ID: \(UIDevice.current.identifierForVendor?.uuidString ?? "nil")", isHTML: false)
        
        present(composer, animated: true)
    }
}

extension UIViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error{
            controller.dismiss(animated: true)
        }
        
        switch result {
        case .cancelled:
            print("Cancelled")
        case .saved:
            print("Failed to send")
        case .sent:
            print("Saved")
        case .failed:
            print("Email Sent")
        @unknown default:
            fatalError()
        }
        
        controller.dismiss(animated: true)
    }
}
