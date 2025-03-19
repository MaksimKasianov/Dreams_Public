//
//  NewMoodVC.swift
//  WeDream
//
//  Created by Kasianov on 20.10.2023.
//

import UIKit

class NewMoodVC: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var searchBt: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var moodsStack: UIStackView!
    
    var selectedMood = 0
    
    var moodsBts = [UIButton]()
    
    weak var newDelegate: NewDreamDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        moodsBts = moodsStack.arrangedSubviews as! [UIButton]
        
        selectedMood = (navigationController as? NewMoodNC)?.selectedMood ?? 0
        selectMoods(select: selectedMood)
        
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
    
    func selectMoods(select: Int) {
        for (i, moodBt) in moodsBts.enumerated() {
            moodBt.layer.cornerRadius = 12
            if i != select {
                moodBt.layer.borderColor = Colors.surface_500.cgColor
                moodBt.layer.borderWidth = 1
                moodBt.backgroundColor = Colors.surface_200
            } else {
                moodBt.layer.borderColor = Colors.primary_500.cgColor
                moodBt.layer.borderWidth = 2
                moodBt.backgroundColor = Colors.primary_50
            }
        }
    }
    
    @IBAction func moodBt(_ sender: UIButton) {
        selectedMood = sender.tag
        selectMoods(select: sender.tag)
    }
    
    @IBAction func addMoodBt(_ sender: UIButton) {
        if let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            MoodBase.shared.add(mood: text, emotion: "emotion-\(selectedMood + 1)")
        } else {
            MoodBase.shared.add(mood: "No note", emotion: "emotion-\(selectedMood + 1)")
        }
        (navigationController as? NewMoodNC)?.newMoodDelegate?.newMood()
        dismiss(animated: true)
    }
    
    @IBAction func closeBt(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension NewMoodVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, text.isEmpty {
            searchBt.alpha = 0.5
            searchBt.isEnabled = false
        } else {
            searchBt.alpha = 1
            searchBt.isEnabled = true
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
