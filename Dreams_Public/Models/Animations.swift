//
//  Animations.swift
//  WeDream
//
//  Created by Kasianov on 20.11.2023.
//

import UIKit
import Foundation

public class Animations {
    static let shared = Animations()
 
    func animateActiveViews(views: [UIView], delayTime: Double = 0.2) {
        for item in 0..<views.count {
            views[item].alpha = 0
            views[item].center.y += 5
        }
        
        for item in 0..<views.count {
            UIView.animate(withDuration: 0.2, delay: TimeInterval(delayTime * Double(item + 1)), options: [.curveEaseInOut, .allowUserInteraction], animations: {
                views[item].alpha = 1
            })
                
            UIView.animate(withDuration: 1.5, delay: TimeInterval(delayTime * Double(item + 1)),
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 0,
                           options: [.curveEaseInOut, .allowUserInteraction]) {
                views[item].center.y -= 5
            }
        }
    }
}
