//
//  DreamDescriptionCell.swift
//  WeDream
//
//  Created by Kasianov on 16.10.2023.
//

import UIKit

class DreamDescriptionCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dreamView: UIStackView!
    @IBOutlet weak var dreamLabel: UILabel!
    
    @IBOutlet weak var menuBt: UIButton!
    @IBOutlet weak var descriptionView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
   
    var dream: DreamData!
    weak var dreamDelegate: NewDreamDelegate?
    weak var parent: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = Fonts.SourceSansPro_Regular(14)
        dreamLabel.font = Fonts.SourceSansPro_Regular(16)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        dreamLabel.text = nil
    }
    
    func setup(dream: DreamData, delegate: NewDreamDelegate, parent: UIViewController) {
        dreamLabel.text = dream.dream
        self.dream = dream
        self.dreamDelegate = delegate
        self.parent = parent
    }
    
    @IBAction func deleteBt(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete dream report", style: .destructive) { _ in
            self.dreamDelegate?.delete(dream: self.dream)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        parent?.present(alertController, animated: true)
    }
}
