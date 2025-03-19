import UIKit

//MARK: - Border
extension UIView {
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
}

//MARK: - Shadow
extension UIView {
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            
            layer.shadowRadius = newValue
            layer.masksToBounds = false
        }
    }
    @IBInspectable
    var shadowOffset : CGSize{
        
        get{
            return layer.shadowOffset
        }set{
            
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor : UIColor {
        get{
            return UIColor.init(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    
    @IBInspectable 
    var shadowOpacity: Float {
        get{
            return layer.shadowOpacity
        }set{
            
            layer.shadowOpacity = newValue / 100
        }
    }
}

//MARK: - Corner Radius
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
    }
    
    @IBInspectable var circleRadius: Bool {
        get {
            return clipsToBounds
        }
        set {
            layer.cornerRadius = frame.size.height / 2
            clipsToBounds = newValue
        }
    }
    
    @IBInspectable var radiusTop: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            clipsToBounds = newValue > 0
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    @IBInspectable var radiusBottom: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            clipsToBounds = newValue > 0
            layer.cornerRadius = newValue
            layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
}

extension UIBezierPath {
    convenience init(rectWithoutCenter frame: CGRect) {
        self.init()

        let space = CGFloat(4)
        let buttonSize = CGFloat(62 / 2)
        
        move(to: CGPoint(x: 0, y: frame.maxY))
        addLine(to: CGPoint(x: 0, y: 16))
        
        addArc(
            withCenter: CGPoint(x: frame.minX + 16, y: 16),
            radius: 16,
            startAngle: .pi,
            endAngle: -.pi / 2,
            clockwise: true
        )
        addArc(
            withCenter: CGPoint(x: frame.midX - buttonSize - space - 10, y: 10),
            radius: 10,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )
        
        
        addArc(
            withCenter: CGPoint(x: frame.midX - 19, y: 10),
            radius: 16,
            startAngle: .pi,
            endAngle: .pi / 2,
            clockwise: false
        )
        addArc(
            withCenter: CGPoint(x: frame.midX - 16 + buttonSize + space, y: 10),
            radius: 16,
            startAngle: .pi / 2,
            endAngle: 0,
            clockwise: false
        )
        
        
        addArc(
            withCenter: CGPoint(x: frame.midX + 10 + buttonSize + space, y: 10),
            radius: 10,
            startAngle: .pi,
            endAngle: -.pi / 2,
            clockwise: true
        )
        
        addArc(
            withCenter: CGPoint(x: frame.maxX - 16, y: 16),
            radius: 16,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )
        
        addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
        close()
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


extension Date {
    func formatted(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.string(from: self)
    }
}

extension FileManager {
    func getDocumentsDirectory() -> URL {
        let paths = self.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getAudioDirectory() -> URL {
        let url = self.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Audio")
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        return url
    }
    
    func remoteAudio(audioName: String) {
        let url = self.getAudioDirectory().appendingPathComponent(audioName)
        if self.fileExists(atPath: url.path) {
            do {
                try self.removeItem(at: url)
            } catch { }
        }
    }
    
    func getImagesDirectory() -> URL {
        let url = self.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Images")
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        return url
    }
}

extension NSMutableAttributedString {
    func setColorForText(textToFind: String, withColor color: UIColor) {
        let range = NSRange(location: 0, length: self.length)
        let options: NSString.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        
        var searchRange = range
        var foundRange: NSRange
        while searchRange.location < self.length {
            foundRange = (self.string as NSString).range(of: textToFind, options: options, range: searchRange)
            
            if foundRange.location != NSNotFound {
                self.addAttribute(.foregroundColor, value: color, range: foundRange)
                searchRange.location = foundRange.location + foundRange.length
                searchRange.length = self.length - searchRange.location
            } else {
                break
            }
        }
    }
}

extension UILabel {
    @IBInspectable var lineHeight: CGFloat {
        get { return 0 }
        set {
            let lineHeight = (font.pointSize * (newValue / 100))
            updateTextAttributes(lineHeight: lineHeight)
        }
    }
    
    @IBInspectable var paragraphSpacing: CGFloat {
        get { return 0 }
        set {
            updateTextAttributes(paragraphSpacing: newValue)
        }
    }
    
    private func updateTextAttributes(lineHeight: CGFloat? = nil, paragraphSpacing: CGFloat? = nil) {
        var mutableParagraphStyle: NSMutableParagraphStyle
        
        if let existingParagraphStyle = attributedText?.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSMutableParagraphStyle {
            mutableParagraphStyle = existingParagraphStyle
        } else {
            mutableParagraphStyle = NSMutableParagraphStyle()
        }
        
        if let lineHeight = lineHeight {
            mutableParagraphStyle.minimumLineHeight = lineHeight
            mutableParagraphStyle.maximumLineHeight = lineHeight
        }
        
        if let paragraphSpacing = paragraphSpacing {
            mutableParagraphStyle.paragraphSpacingBefore = paragraphSpacing
        }
        
        attributedText = NSAttributedString(
            string: text ?? "",
            attributes: [.paragraphStyle : mutableParagraphStyle]
        )
    }
}

extension UIViewController {
    func showSettindsVC() {
        let settingsVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "settingsVC")
        settingsVC.hidesBottomBarWhenPushed = true
        
        if let button = (tabBarController?.tabBar as? CustomizedTabBar)?.middleBtn {
            button.superview?.isUserInteractionEnabled = false
        }
        
        show(settingsVC, sender: self)
    }
    
    func showPremiumVC() {
        let premiumVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "premiumVC")
        
        premiumVC.modalPresentationStyle = .fullScreen
        
        present(premiumVC, animated: true)
    }
}

extension UIView {
    func addShadow(y: Int) {
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.24
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: y)
        self.layer.shadowColor = Colors.shadowColor.cgColor
    }
}
