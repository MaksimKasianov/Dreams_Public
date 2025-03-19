//
//  ProcessButton.swift
//  DreamApp
//
//  Created by Kasianov on 11.04.2024.
//

import UIKit

class ProcessButton: UIButton {
    var title: String? = nil
    
    @IBInspectable
    var processText: String = ""
    
    var isLoading = false {
        didSet {
            updateView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        title = titleLabel?.text ?? ""
    }
    
    func updateView() {
        if isLoading {
            setTitle(processText, for: .normal)
            
            isEnabled = false
        } else {
            setTitle(title, for: .normal)
            
            isEnabled = true
        }
    }
}
