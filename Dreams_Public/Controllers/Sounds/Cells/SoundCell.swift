//
//  SoundCell.swift
//  DreamApp
//
//  Created by Kasianov on 15.04.2024.
//

import UIKit

class SoundCell: UICollectionViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var aligmentStack: UIStackView!
    @IBOutlet weak var soundImg: UIImageView!
    
    let freeSounds = ["Wind", "Sea Waves", "Seagulls", "Sea Ambience"]
    
    var sound: String = "" {
        didSet {
            imageView.image = UIImage(named: sound.lowercased())
            nameLabel.text = sound
            
            lockView.isHidden = Shared.shared.isPremium
            
            for free in freeSounds {
                if free == sound {
                    lockView.isHidden = true
                }
            }
        }
    }
    
    var isSelect: Bool = false {
        didSet {
            if isSelect {
                container.layer.borderColor = Colors.primary_500.cgColor
                container.backgroundColor = Colors.primary_500
                soundImg.tintColor = Colors.primary_50
            } else {
                container.layer.borderColor = Colors.surface_50.cgColor
                container.backgroundColor = Colors.surface_100
                soundImg.tintColor = Colors.primary_500
            }
        }
    }
}
