//
//  ChatTextView.swift
//  DreamApp
//
//  Created by Kasianov on 27.03.2024.
//

import UIKit


class ChatTextView: UITextView {

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
    
    private var maxHeight: CGFloat = 0
    private var heightConstraint: NSLayoutConstraint!
    private var placeholderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        maxHeight = font!.lineHeight * CGFloat(3) + (textContainerInset.top + textContainerInset.bottom)
        
        isScrollEnabled = false
        
        heightConstraint = heightAnchor.constraint(equalToConstant: maxHeight)
        heightConstraint.isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
        
        placeholderLabel = UILabel()
        placeholderLabel.font = Fonts.SourceSansPro_Regular(20)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
    
    func updateText(_ newText: String) {
        text = newText
        textViewDidChange(self)
    }
    
    @objc private func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !self.text.isEmpty
            
        let estimatedSize = sizeThatFits(CGSize(width: frame.width, height: maxHeight))
        
        guard estimatedSize.height < maxHeight else {
            heightConstraint.constant = maxHeight
            isScrollEnabled = true
            return
        }
        
        heightConstraint.constant = estimatedSize.height
        isScrollEnabled = false
    }
}
