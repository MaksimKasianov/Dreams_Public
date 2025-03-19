//
//  TimerManager.swift
//  DreamApp
//
//  Created by Kasianov on 25.04.2024.
//

import Foundation

class TimerManager {
    static let shared = TimerManager()
    
    var timer: Timer?
    @Published var time: Int = 0
    var timeLeft = 0
    
    func createTimer() {
        if timer == nil {
            let timer = Timer(timeInterval: 1.0,
                              target: self,
                              selector: #selector(updateTimer),
                              userInfo: nil,
                              repeats: true)
            RunLoop.current.add(timer, forMode: .common)
            timer.tolerance = 0.1
            
            
            self.timer = timer
            self.time = self.timeLeft
        }
    }
    
    @objc func updateTimer() {
        time -= 1
        
        if time <= 0 {
            stopTimer()
            AudioPlayerManager.shared.stopAllAudio()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        time = 0
    }
}
