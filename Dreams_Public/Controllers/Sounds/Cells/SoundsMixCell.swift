//
//  SoundsMixCell.swift
//  DreamApp
//
//  Created by Kasianov on 26.04.2024.
//

import UIKit

class SoundsMixCell: UITableViewCell {

    @IBOutlet weak var playImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var soundsLabel: UILabel!
    
    var selectedMix: SoundsMixEntity!
    
    var isSelect: Bool = false {
        didSet {
            if isSelect {
                playImg.image = UIImage(named: "stop-icon")
            } else {
                playImg.image = UIImage(named: "play-min-icon")
            }
        }
    }
            
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        soundsLabel.text = nil
    }
    
    func setup(mix: SoundsMixEntity) {
        selectedMix = mix
        nameLabel.text = mix.name
        soundsLabel.text = mix.sounds
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
