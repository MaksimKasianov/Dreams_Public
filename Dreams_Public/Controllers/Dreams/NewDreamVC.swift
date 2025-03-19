//
//  NewDreamVC.swift
//  WeDream
//
//  Created by Kasianov on 13.10.2023.
//

import UIKit
import Speech

class NewDreamVC: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: CustomTextView!
    
    @IBOutlet weak var micBt: UIButton!
    @IBOutlet weak var searchBt: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var dataArray = [String]()
    
    weak var newDelegate: NewDreamDelegate?
    
    var isTapped: Bool = false
    let speechRec = SpeechRec.shared
    
    var isFirstDream = false
    
    @IBOutlet weak var amplitudeView: UIStackView!
    @IBOutlet weak var waveformView: WaveformView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFirstDream {
            navigationItem.title = "Your last dream"
            titleLabel.isHidden = true
        } else {
            navigationItem.hidesBackButton = true
        }
        
        textView.delegate = self
        
        searchBt.alpha = 0.5
        searchBt.isEnabled = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        speechRec.parentVC = self
        self.isTapped = false
        
        amplitudeView.isHidden = true
        
        micBt.isHidden = !Shared.shared.isMicrophone
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
        if isTapped {
            stopRecording()
        }
    }
    
    @IBAction func searchBt(_ sender: UIButton) {
        textView.resignFirstResponder()
        
        let searchVC = UIStoryboard(name: "Dreams", bundle: nil).instantiateViewController(withIdentifier: "dreamSearchVC") as! DreamSearchVC
        
        searchVC.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        searchVC.isFirstDream = isFirstDream
        
        show(searchVC, sender: nil)
    }
    
    @IBAction func closeBt(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    //MARK: -
    @IBAction func recordBt(_ sender: UIButton) {
        if isTapped == false {
            startRecording()
        } else {
            stopRecording()
        }
    }

    func startRecording() {
        self.isTapped = true
        self.micBt.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        textView.resignFirstResponder()
        searchBt.alpha = 0.5
        searchBt.isEnabled = false
        textView.isEditable = false
        amplitudeView.isHidden = false
        waveformView.updateWithLevel(0)
        statusLabel.isHidden = true
        
        self.speechRec.start(text: textView.text)
        print("START")
    }

    func stopRecording() {
        self.isTapped = false
        self.micBt.setImage(UIImage(named: "microphone-icon"), for: .normal)
        textView.isEditable = true
        amplitudeView.isHidden = true
        statusLabel.isHidden = false
        checkInput()
        
        speechRec.stop()
        print("STOP")
    }
    
    func textOutput(_ text: String) {
        self.textView.updateText(text.description)
        self.textViewDidChange(textView)
        
        self.textView.scrollToBottom()
    }
    
    func amplitudeDB(db: Float) {
        waveformView.updateWithLevel(CGFloat(db))
    }
    
    func checkInput() {
        if dataArray.count <= 4 {
            statusLabel.text = "🤔  Maybe a few more words?"
            searchBt.alpha = 0.5
            searchBt.isEnabled = false
        } else {
            if dataArray.count < 20 {
                statusLabel.text = "🎉  Keep going! More details = more accurate review!"
            } else {
                statusLabel.text = "😍  Super! Keep going!"
            }
            
            if !isTapped {
                searchBt.alpha = 1
                searchBt.isEnabled = true
            }
        }
    }
}

extension NewDreamVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            dataArray = text.components(separatedBy: [",", " ", "!",".","?","\n"])
            print(dataArray)
        }
        checkInput()
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

extension UITextView {
    func scrollToBottom() {
        let range = NSMakeRange(self.text.count - 1, 1)
        self.scrollRangeToVisible(range)
    }
}
