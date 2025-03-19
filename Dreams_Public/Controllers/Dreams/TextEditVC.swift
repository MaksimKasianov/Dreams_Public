//
//  TextEditVC.swift
//  WeDream
//
//  Created by Kasianov on 18.10.2023.
//

import UIKit

class TextEditVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var textView: CustomTextView!
    
    @IBOutlet weak var saveBt: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
       
    var isDream = false
    var isNotes = false
    
    var statusText: String!
    var notesText: String!
    weak var editDelegate: EditDreamDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        if isDream {
            titleLabel.text = "Your Dream"
            textView.placeholderText = "Enter your dream keywords..."
            
        }
        
        if isNotes {
            titleLabel.text = "Notes"
            textView.placeholderText = "Place for the notes to this dream"
        }
        
        textView.updateText(notesText)
        statusLabel.text = statusText
        
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.delegate = self
        
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
                    self.bottomConstraint.constant = keyBoardRect.size.height - self.view.safeAreaInsets.bottom + 16
                }
                self.view.layoutIfNeeded()
            })
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        textView.resignFirstResponder()
    }
    
    @IBAction func saveBt(_ sender: UIButton) {
        if isNotes {
            let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            editDelegate?.editNotes(notes: text)
        } else if isDream {
            let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            editDelegate?.editDream(dream: text)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

extension TextEditVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), text.isEmpty {
            if isDream {
                saveBt.alpha = 0.5
                saveBt.isEnabled = false
            }
        } else {
            if isDream {
                saveBt.alpha = 1
                saveBt.isEnabled = true
            }
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

enum TextEditor {
    case dream
    case note
}
