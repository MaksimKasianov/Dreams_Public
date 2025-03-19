//
//  StaticTextView.swift
//  DreamApp
//
//  Created by Kasianov on 10.04.2024.
//

import UIKit

class StaticTextView: UITextView {

    @IBInspectable var placeholderText: String = "" {
        didSet {
            if let label = placeholderLabel {
                label.text = placeholderText
            }
        }
    }
    
    @IBInspectable var placeholderColor: UIColor = .tintColor {
        didSet {
            if let label = placeholderLabel {
                label.textColor = placeholderColor
            }
        }
    }
    
    private var minHeight: CGFloat = 0
    private var heightConstraint: NSLayoutConstraint!
    private var placeholderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        minHeight = font!.lineHeight * CGFloat(3) + (textContainerInset.top + textContainerInset.bottom)
        
        isScrollEnabled = false
        isEditable = false
        isSelectable = false
        
        heightConstraint = heightAnchor.constraint(equalToConstant: minHeight)
        heightConstraint.isActive = true
        
        placeholderLabel = UILabel()
        placeholderLabel.font = font
        placeholderLabel.text = placeholderText
        placeholderLabel.textColor = placeholderColor
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            placeholderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 16),
            placeholderLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            placeholderLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 16)
        ])
    }
    
    func setText(_ newText: String) {
        text = newText
        textViewDidChange()
    }
    
    func textViewDidChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
            
        let estimatedSize = sizeThatFits(CGSize(width: frame.width, height: contentSize.height))
        
        if estimatedSize.height > minHeight {
            heightConstraint.constant = estimatedSize.height
        } else {
            heightConstraint.constant = minHeight
        }
    }
}
