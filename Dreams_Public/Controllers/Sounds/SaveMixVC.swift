//
//  SaveMixVC.swift
//  DreamApp
//
//  Created by Kasianov on 26.04.2024.
//

import UIKit

class SaveMixVC: UIViewController {

    @IBOutlet weak var nameMixTF: UITextField!
    @IBOutlet weak var saveBt: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveBt.isEnabled = false
        saveBt.alpha = 0.5
        
        nameMixTF.delegate = self

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameMixTF.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        nameMixTF.resignFirstResponder()
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        if let nameString = nameMixTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !nameString.isEmpty {
            saveBt.isEnabled = true
            saveBt.alpha = 1
        } else {
            saveBt.isEnabled = false
            saveBt.alpha = 0.5
        }
    }
    
    @IBAction func closeBt(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func saveBt(_ sender: UIButton) {
        guard let name = nameMixTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            nameMixTF.becomeFirstResponder()
            return
        }
        
        let audioPlayers = AudioPlayerManager.shared.audioPlayers
        
        var sounds: String {
            var text = ""
            for sound in audioPlayers {
                text.append("\(sound.key), ")
            }
            
            return String(text.dropLast(2))
        }
        
        print(sounds)
        
        let mix = SoundsMixBase.shared.add(name: name, sounds: sounds)
        
        AudioPlayerManager.shared.isSoundsMix = mix
        dismiss(animated: true)
    }
}

extension SaveMixVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       textField.resignFirstResponder()
       return true
    }
}
