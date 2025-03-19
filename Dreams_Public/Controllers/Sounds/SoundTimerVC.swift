//
//  SoundTimerVC.swift
//  DreamApp
//
//  Created by Kasianov on 25.04.2024.
//

import UIKit

class SoundTimerVC: UIViewController {

    @IBOutlet weak var countDownTimer: UIDatePicker!
    @IBOutlet weak var cancelTimerBt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if TimerManager.shared.timer != nil {
            cancelTimerBt.isHidden = false
        } else {
            cancelTimerBt.isHidden = true
        }
        
        countDownTimer.setValue(Colors.shades_gray_800, forKeyPath: "textColor")
    }
    
    @IBAction func valueChanged(_ sender: UIDatePicker) {
        print("\(sender.countDownDuration) sec")
    }
    
    @IBAction func newTimer(_ sender: UIButton) {
        TimerManager.shared.timeLeft = Int(countDownTimer.countDownDuration)
        
        TimerManager.shared.createTimer()
        
        dismiss(animated: true)
    }
    
    @IBAction func cancelBt(_ sender: UIButton) {
        TimerManager.shared.stopTimer()
        
        dismiss(animated: true)
    }
    
    @IBAction func closeBt(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
