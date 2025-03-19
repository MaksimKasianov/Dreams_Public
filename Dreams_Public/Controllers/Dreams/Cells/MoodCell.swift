//
//  MoodCell.swift
//  WeDream
//
//  Created by Kasianov on 20.10.2023.
//

import UIKit

class MoodCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dreamView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var menuBt: UIButton!
    @IBOutlet weak var descriptionView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
   
    var mood: MoodData!
    weak var moodDelegate: NewMoodDelegate?
    weak var parent: UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.font = Fonts.SourceSansPro_Regular(14)
        textView.font = Fonts.SourceSansPro_Regular(16)
        
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textView.text = nil
    }
    
    func setup(mood: MoodData, delegate: NewMoodDelegate, parent: UIViewController) {
        textView.text = mood.mood
        self.mood = mood
        self.moodDelegate = delegate
        self.parent = parent
    }
    
    @IBAction func deleteBt(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete mood note report", style: .destructive) { _ in
            self.moodDelegate?.delete(mood: self.mood)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        parent?.present(alertController, animated: true)
    }
}
