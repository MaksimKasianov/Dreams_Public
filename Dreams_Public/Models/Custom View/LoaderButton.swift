//
//  LoaderButton.swift
//  testAssistent
//
//  Created by Kasianov on 25.03.2024.
//

import UIKit

class LoaderButton: UIButton {

    var title: String? = nil
    var image: UIImage? = nil
    var spinner = UIActivityIndicatorView()
    
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
        spinner.hidesWhenStopped = true
        spinner.color = .white
        spinner.style = .medium
        
        image = imageView?.image ?? nil
        title = titleLabel?.text ?? ""
        
        addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func updateView() {
        if isLoading {
            spinner.startAnimating()
            setImage(nil, for: .normal)
            setTitle(nil, for: .normal)
            
            isEnabled = false
        } else {
            spinner.stopAnimating()
            setImage(image, for: .normal)
            setTitle(title, for: .normal)
            
            isEnabled = true
        }
    }
}
