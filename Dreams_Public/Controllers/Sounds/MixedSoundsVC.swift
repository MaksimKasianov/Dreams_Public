//
//  MixedSoundsVC.swift
//  DreamApp
//
//  Created by Kasianov on 16.04.2024.
//

import UIKit
import Combine

class MixedSoundsVC: UIViewController {

    @IBOutlet weak var playBt: UIButton!
    @IBOutlet weak var selectedSounds: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var mixImage: UIImageView!
    @IBOutlet weak var mixBt: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    let playerManager = AudioPlayerManager.shared
    var cancellables = Set<AnyCancellable>()
    
    let timerManager = TimerManager.shared
    
    var array = [String]() {
        didSet {
            self.selectedSounds.text = "Selected sounds (\(self.array.count)/20)"
            
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        playerManager.$audioPlayers
            .sink { audioPlayers in
                if !audioPlayers.isEmpty {
                    self.array.removeAll()
                    
                    var players = [String]()
                    
                    for player in audioPlayers {
                        players.append(player.key)
                    }
                    
                    self.array = players
                    
                } else {
                    self.playerManager.isPause = true
                    self.dismiss(animated: true)
                }
            }
            .store(in: &cancellables)
        
        playerManager.$isPause
            .sink { isPause in
                DispatchQueue.main.async {
                    if isPause {
                        self.playBt.setImage(UIImage(named: "play-icon"), for: .normal)
                        self.playLabel.text = "Play sounds"
                    } else {
                        self.playBt.setImage(UIImage(named: "pause-icon"), for: .normal)
                        self.playLabel.text = "Pause sounds"
                    }
                }
            }
            .store(in: &cancellables)
        
        playerManager.$isSoundsMix
            .sink { soundsMix in
                DispatchQueue.main.async {
                    self.mixBt.removeTarget(nil, action: nil, for: .allEvents)
                    
                    if soundsMix != nil {
                        self.mixImage.image = UIImage(named: "heart-fill-icon")
                        self.mixBt.addTarget(self, action: #selector(self.deleteMixBt), for: .touchUpInside)
                    } else {
                        self.mixImage.image = UIImage(named: "heart-icon")
                        self.mixBt.addTarget(self, action: #selector(self.saveMixBt), for: .touchUpInside)
                    }
                }
            }
            .store(in: &cancellables)
        
        timerManager.$time
            .sink { time in
                DispatchQueue.main.async {
                    if self.timerManager.timer == nil {
                        self.timerLabel.text = "Add Timer"
                    } else {
                        self.timerLabel.text = self.secondsToHoursMinutesSeconds(time)
                    }
                }
            }
            .store(in: &cancellables)
        
        setupBottomBar()
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> String {
        let hour = seconds / 3600
        let minute = (seconds % 3600) / 60
        let second = (seconds % 3600) % 60

        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
    func setupBottomBar() {
        playBt.layer.shadowRadius = 12
        playBt.layer.shadowOpacity = 1
        playBt.layer.masksToBounds = false
        playBt.layer.shadowOffset = CGSize(width: 0, height: 4)
        playBt.layer.shadowColor = Colors.shadowColor.cgColor
        
        let rectMask = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 49)
        let maskPath = UIBezierPath.init(rectWithoutCenter: rectMask)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = maskPath.cgPath
        
        shapeLayer.fillColor = Colors.surface_200.cgColor
        shapeLayer.lineWidth = 1.0
        
        bottomView.layer.insertSublayer(shapeLayer, at: 1)
        bottomView.addShadow(y: -2)
        bottomView.layer.shadowPath = UIBezierPath(rect:
                                                    CGRect(x: 0,
                                                           y: 0,
                                                           width:  bottomView.bounds.width,
                                                           height: 49 / 2)).cgPath
    }
    
    @IBAction func closeBt(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func playBt(_ sender: UIButton) {
        playerManager.pauseResume()
    }
    
    @IBAction func clearBt(_ sender: UIButton) {
        playerManager.stopAllAudio()
        timerManager.stopTimer()
    }
      
    @IBAction func timerBt(_ sender: UIButton) {
        let timerVC = UIStoryboard(name: "Sounds", bundle: nil).instantiateViewController(withIdentifier: "soundTimerVC")
        present(timerVC, animated: true)
    }
    
    @objc func saveMixBt() {
        let saveMixVC = UIStoryboard(name: "Sounds", bundle: nil).instantiateViewController(withIdentifier: "saveMixVC")
        
        present(saveMixVC, animated: true)
    }
    
    @objc func deleteMixBt() {
        print("DELETE")
        if let mix = AudioPlayerManager.shared.isSoundsMix {
            SoundsMixBase.shared.delete(mix: mix)
            AudioPlayerManager.shared.isSoundsMix = nil
        }
    }
}

extension MixedSoundsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SoundTableCell
        
        cell.sound = array[indexPath.item]
        return cell
    }   
}
