//
//  DreamCell.swift
//  WeDream
//
//  Created by Kasianov on 11.10.2023.
//

import UIKit

class DreamCell: UICollectionViewCell {
    
    @IBOutlet weak var img: CustomImageView!
    @IBOutlet weak var title: UILabel!
    
    var url: String? {
        didSet {
            guard let url = url else { return }
            img.isLoading = true
            img.loadImage(with: url)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        title.text = nil
    }
    
    func setup(dream: Dream) {
        self.url = dream.title
        
        title.text = dream.title
    }
}
