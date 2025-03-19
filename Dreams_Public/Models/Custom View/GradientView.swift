//
//  GradientView.swift
//  WeDream
//
//  Created by Kasianov on 17.11.2023.
//

import Foundation
import UIKit

@IBDesignable
public class GradientView: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.0 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   1.0 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }

}

@IBDesignable
public class GradientImage: UIImageView {
    @IBInspectable var startColor: UIColor = .black { didSet { updateGradient() }}
    @IBInspectable var endColor: UIColor = .white { didSet { updateGradient() }}
    @IBInspectable var startLocation: Double = 0.0 { didSet { updateGradient() }}
    @IBInspectable var endLocation: Double = 1.0 { didSet { updateGradient() }}
    @IBInspectable var horizontalMode: Bool = false { didSet { updateGradient() }}
    @IBInspectable var diagonalMode: Bool = false { didSet { updateGradient() }}
    
    private var gradientLayer: CAGradientLayer!
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }
    
    private func updateGradient() {
        gradientLayer?.removeFromSuperlayer()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [NSNumber(value: startLocation), NSNumber(value: endLocation)]
        
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
        
        layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
    }
}
