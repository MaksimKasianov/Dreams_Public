import UIKit

@IBDesignable
class CustomizedTabBar: UITabBar {
    private var shapeLayer: CAShapeLayer?
    
    let centerView = UIStackView()
    let actionBtn = UIButton()
    let middleBtn = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    private func addShape() {
        let rectMask = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        let maskPath = UIBezierPath.init(rectWithoutCenter: rectMask)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = maskPath.cgPath
        
        shapeLayer.fillColor = Colors.surface_200.cgColor
        shapeLayer.lineWidth = 1.0
        
        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        
        self.shapeLayer = shapeLayer
        
        self.addShadow(y: -2)
        self.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                               y: 0,
                                                               width:  bounds.width,
                                                               height: 49 / 2)).cgPath
    }
    
    
    override func draw(_ rect: CGRect) {
        self.addShape()
        
        //setupCenterButton()
        self.items?[1].titlePositionAdjustment = UIOffset(horizontal: -14, vertical: 0)
        self.items?[3].titlePositionAdjustment = UIOffset(horizontal: 14, vertical: 0)
        
        let normal = Colors.surface_700
        let selected = Colors.primary_500
        self.unselectedItemTintColor = normal
        self.tintColor = selected
        
        if let items = self.items {
            for item in items {
                item.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.PPWoodland_Regular(12)], for: .normal)
            }
        }
    }
    
    func setupCenterButton() {
        centerView.backgroundColor = .clear
        centerView.distribution = .equalSpacing
        centerView.alignment = .center
        centerView.axis = .vertical
        
        centerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(centerView)
        
        middleBtn.backgroundColor = Colors.primary_500
        middleBtn.tintColor = Colors.surface_50
        middleBtn.setImage(UIImage(named: "add-dreams-icon"), for: .normal)
        
        middleBtn.layer.cornerRadius = 16
        middleBtn.layer.shadowRadius = 12
        middleBtn.layer.shadowOpacity = 1
        middleBtn.layer.masksToBounds = false
        middleBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        middleBtn.layer.shadowColor = Colors.shadowColor.cgColor
        
        centerView.addArrangedSubview(middleBtn)
        
        let titleLabel = UILabel()
        titleLabel.text = "Tell Your Dream"
        titleLabel.font = Fonts.PPWoodland_Regular(14)
        titleLabel.textColor = Colors.primary_500
        
        centerView.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            middleBtn.widthAnchor.constraint(equalToConstant: 62),
            middleBtn.heightAnchor.constraint(equalToConstant: 62),
            centerView.widthAnchor.constraint(equalToConstant: 102),
            centerView.heightAnchor.constraint(equalToConstant: 89),
            centerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            centerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let centerButtonPoint = centerView.convert(point, from: self)
        if centerView.bounds.contains(centerButtonPoint) {
            return centerView.hitTest(centerButtonPoint, with: event)
        }
        
        return super.hitTest(point, with: event)
    }
}
