//
//  NewMoodNC.swift
//  WeDream
//
//  Created by Kasianov on 20.10.2023.
//

import UIKit

class NewMoodNC: UINavigationController {

    weak var newMoodDelegate: NewMoodDelegate?
    
    var selectedMood = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (navigationController?.viewControllers[0] as? NewMoodVC)?.selectedMood = selectedMood
    }
}
