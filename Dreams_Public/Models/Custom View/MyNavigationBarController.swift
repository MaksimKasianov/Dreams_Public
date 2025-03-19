//
//  MyNavigationBarController.swift
//  WeDream
//
//  Created by Kasianov on 11.10.2023.
//

import UIKit

class MyNavigationBarController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.shadowColor = .clear
        appearance.shadowImage = nil
        
        appearance.backgroundColor = Colors.surface_200
        appearance.titleTextAttributes = [NSAttributedString.Key.font: Fonts.PPWoodland_Regular(17), NSAttributedString.Key.foregroundColor: Colors.shades_gray_800]
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.font: Fonts.PPWoodland_Regular(32), NSAttributedString.Key.foregroundColor: Colors.shades_gray_800]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        
        navigationBar.tintColor = Colors.primary_500
        
        navigationBar.prefersLargeTitles = true
        
        navigationBar.addShadow(y: 2)
    }
}
