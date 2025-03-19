//
//  DreamInterpretationVC.swift
//  WeDream
//
//  Created by Kasianov on 12.10.2023.
//

import UIKit

class DreamInterpretationVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    var interpretation: Dream?
    
    @IBOutlet weak var dreamImage: CustomImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var helpfulView: UIView!
    @IBOutlet weak var thankView: UIView!
    
    @IBOutlet weak var dislikeBt: UIButton!
    @IBOutlet weak var likeBt: UIButton!
    @IBOutlet weak var closeBt: UIButton!
    
    var url: String? {
        didSet {
            guard let url = url else { return }
            dreamImage.isLoading = true
            dreamImage.loadImage(with: url, finding: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dream = interpretation {
            if navigationController != nil {
                closeBt.isHidden = true
            } else {
                closeBt.isHidden = false
            }
            
            self.url = dream.title
            
            titleLabel.text = dream.title
            summaryLabel.text = dream.detailed
        
            if HelpfulBase.shared.checkHelpful(dream: dream.title) {
                helpfulView.isHidden = true
                thankView.isHidden = false
            } else {
                helpfulView.isHidden = false
                thankView.isHidden = true
            }
        }
    }
    
    @IBAction func dislikeBt(_ sender: UIButton) {
        if let dream = interpretation {
            HelpfulBase.shared.add(dream: dream.title)
            AmplitudeManager.shared.eventTrack(type: "Was it helpful?", properties: [dream.title : false])
        }
        helpfulView.isHidden = true
        thankView.isHidden = false
    }
    
    @IBAction func likeBt(_ sender: UIButton) {
        if let dream = interpretation {
            HelpfulBase.shared.add(dream: dream.title)
            AmplitudeManager.shared.eventTrack(type: "Was it helpful?", properties: [dream.title : true])
        }
        helpfulView.isHidden = true
        thankView.isHidden = false
    }
    
    @IBAction func closeBt(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
