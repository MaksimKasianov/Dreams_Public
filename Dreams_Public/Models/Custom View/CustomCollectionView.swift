//
//  CustomCollectionView.swift
//  DreamApp
//
//  Created by Kasianov on 22.04.2024.
//

import UIKit

class CustomCollectionView: UICollectionView {
    
    var sectionsData = [[String]]() {
        didSet {
            draw()
        }
    }
    
    func draw() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = Colors.surface_400.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.zPosition = -1
        let path = CGMutablePath()
        
        for (i, section) in sectionsData.enumerated() {
            let cellWidth = (16 + 77 + 16)
            
            let x = ((cellWidth * (i + 1)) + (cellWidth * i)) / 2
            var y = 16
            
            if i % 2 != 0 {
                y = 44
            }
            
            path.addLines(between: [CGPoint(x: x, y: y),
                                    CGPoint(x: x, y: 105 * section.count)])
        }
        shapeLayer.path = path
        
        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        
        self.shapeLayer = shapeLayer
    }
    
    private var shapeLayer: CAShapeLayer?
    
}
