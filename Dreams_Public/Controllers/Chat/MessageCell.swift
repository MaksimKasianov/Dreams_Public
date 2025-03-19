//
//  MessageCell.swift
//  testAssistent
//
//  Created by Kasianov on 21.03.2024.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        messageLabel.text = nil
        bgView.backgroundColor = .lightGray
        
        
    }
    
    func configure(with message: Message) {
        bgView.layer.cornerRadius = 16
        if message.role == "user" {
            
            bgView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
            
            bgView.backgroundColor = Colors.surface_50
        } else {
            
            bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
            bgView.backgroundColor = Colors.surface_800
        }
        
        messageLabel.text = message.content
    }
}
