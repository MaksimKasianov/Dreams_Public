//
//  SoundTableCell.swift
//  DreamApp
//
//  Created by Kasianov on 16.04.2024.
//

import UIKit

class SoundTableCell: UITableViewCell {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var volumeSlider: UISlider!
    
    var sound: String = "" {
        didSet {
            imgView.image = UIImage(named: sound.lowercased())
            nameLabel.text = sound
            volumeSlider.value = AudioPlayerManager.shared.audioPlayers[sound]?.volume ?? 0.5
        }
    }
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        AudioPlayerManager.shared.audioPlayers[sound]?.volume = sender.value
    }
    
    @IBAction func closeBt(_ sender: UIButton) {
        AudioPlayerManager.shared.checkAudio(fileName: sound)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
