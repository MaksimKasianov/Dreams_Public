//
//  YourNameVC.swift
//  WeDream
//
//  Created by Kasianov on 17.11.2023.
//

import UIKit

class YourNameVC: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextBt: UIButton!
    @IBOutlet weak var skipBt: UIBarButtonItem!
    
    weak var person: PersonData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if person != nil {
            nextBt.setTitle("Save", for: .normal)
            navigationItem.rightBarButtonItem = nil
        }
        
        if let name = person?.name {
            nameTF.text = name
            nextBt.setTitle("Save", for: .normal)
            nextBt.isEnabled = true
        } else {
            nextBt.isEnabled = false
            nextBt.alpha = 0.5
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        if let userInfo = notification.userInfo {
            let animationDuration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            let keyBoardRect = view.convert(keyboardScreenEndFrame, from: nil)
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: .beginFromCurrentState,
                           animations: {
                if notification.name == UIResponder.keyboardWillHideNotification {
                    self.bottomConstraint.constant = 16
                } else {
                    self.bottomConstraint.constant = keyBoardRect.size.height - self.view.safeAreaInsets.bottom + 24
                }
                self.view.layoutIfNeeded()
            })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nameTF.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        nameTF.resignFirstResponder()
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        if let nameString = nameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !nameString.isEmpty {
            nextBt.isEnabled = true
            nextBt.alpha = 1
        } else {
            nextBt.isEnabled = false
            nextBt.alpha = 0.5
        }
    }
    
    @IBAction func nextBt(_ sender: UIButton) {
        guard let nameString = nameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !nameString.isEmpty else {
            nameTF.becomeFirstResponder()
            return
        }
        
        if let person = person {
            person.name = nameString
            PersonBase.shared.edit(complection: { 
                Shared.shared.personData = person
            })
            
            navigationController?.popViewController(animated: true)
        } else {
            Shared.shared.registerData.name = nameString
            
            let youBornVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "youBornVC")
            show(youBornVC, sender: self)
        }
    }
    
    
    @IBAction func skipBt(_ sender: Any) {
        Shared.shared.registerData.name = nil
        
        let youBornVC = UIStoryboard(name: "Registration", bundle: nil).instantiateViewController(withIdentifier: "youBornVC")
        show(youBornVC, sender: self)
    }
}
