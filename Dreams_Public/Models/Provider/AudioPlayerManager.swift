//
//  AudioPlayerManager.swift
//  DreamApp
//
//  Created by Kasianov on 15.04.2024.
//

import Foundation
import AVFoundation

final class AudioPlayerManager: NSObject {
    static let shared = AudioPlayerManager()
    
    @Published var audioPlayers: [String: AVAudioPlayer] = [:]
    
    @Published var isPause: Bool = false
    
    @Published var isSoundsMix: SoundsMixEntity? = nil
    
    func checkAudio(fileName: String) {
        isSoundsMix = nil
        
        if audioPlayers[fileName] != nil {
            stopAudio(fileName: fileName)
        } else {
            playAudio(fileName: fileName)
        }
    }
     
    func playAudio(fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "m4a") else { return }
        
        DispatchQueue.global().async {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer.numberOfLoops = -1
                audioPlayer.volume = 0.5
                audioPlayer.prepareToPlay()
                
                DispatchQueue.main.async {
                    self.audioPlayers[fileName] = audioPlayer
                    self.resumeAllAudio()
                }
            } catch let error {
                print("Audio player error: \(error.localizedDescription)")
            }
        }
    }
    
    func stopAudio(fileName: String) {
        audioPlayers[fileName]?.stop()
        audioPlayers.removeValue(forKey: fileName)
    }
    
    func pauseAllAudio() {
        isPause = true
        
        for audioPlayer in audioPlayers {
            audioPlayer.value.pause()
        }
    }

    func resumeAllAudio() {
        isPause = false
        
        for audioPlayer in audioPlayers {
            audioPlayer.value.play()
        }
    }
    
    func stopAllAudio() {
        for audioPlayer in audioPlayers {
            audioPlayer.value.stop()
        }
        
        audioPlayers.removeAll()
    }
    
    func pauseResume() {
        if isPause {
            resumeAllAudio()
        } else {
            pauseAllAudio()
        }
    }
    
    func checkMix(mix: SoundsMixEntity) {
        if isSoundsMix == mix {
            stopAllAudio()
            isSoundsMix = nil
        } else {
            stopAllAudio()
            playMix(mix: mix)
            isSoundsMix = mix
        }
    }
    
    func playMix(mix: SoundsMixEntity) {
        if let sounds = mix.sounds?.components(separatedBy: ", ") {
            isSoundsMix = mix
            
            for sound in sounds {
                playAudio(fileName: sound)
            }
        }
    }
}

