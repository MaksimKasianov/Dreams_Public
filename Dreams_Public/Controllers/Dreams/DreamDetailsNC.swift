//
//  DreamDetailsNC.swift
//  WeDream
//
//  Created by Kasianov on 18.10.2023.
//

import UIKit

class DreamDetailsNC: UINavigationController {

    var selectedDream: DreamData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationBar.tintColor = Colors.primary_900
        self.navigationBar.barTintColor = Colors.surface_200
        self.navigationBar.backgroundColor = Colors.surface_200
        self.navigationBar.shadowImage = nil
        
        self.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: Fonts.PPWoodland_Regular(17), NSAttributedString.Key.foregroundColor: Colors.shades_gray_800]
        self.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.font: Fonts.PPWoodland_Regular(32), NSAttributedString.Key.foregroundColor: Colors.shades_gray_800]
        
        if let dream = selectedDream {
            (self.viewControllers.first as! DreamDetailsVC).selectedDream = dream
        } else {
            dismiss(animated: true)
        }
    }
}
