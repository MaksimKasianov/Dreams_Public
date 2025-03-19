//
//  CustomTextView.swift
//  DreamApp
//
//  Created by Kasianov on 27.03.2024.
//

import UIKit

class CustomTextView: UITextView {
    @IBInspectable var minimumLines: Int = 4
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
    
    private var placeholderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let minimumHeight = font!.lineHeight * 4 + (textContainerInset.top + textContainerInset.bottom)
        print(minimumHeight)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange(_:)), name: UITextView.textDidChangeNotification, object: nil)
        
        placeholderLabel = UILabel()
        placeholderLabel.font = Fonts.SourceSansPro_Regular(20)
        placeholderLabel.text = placeholderText
        placeholderLabel.textColor = placeholderColor
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: minimumHeight),
            
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
    }
}
