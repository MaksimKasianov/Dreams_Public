import UIKit.UIFont

typealias Fonts = UIFont

extension Fonts {
    static func Estrella_Bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Estrella Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static func Estrella_Medium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Estrella Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func SourceSansPro_Regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "SourceSansPro-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func SourceSansPro_SemiBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "SourceSansPro-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    static func PPWoodland_Regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PPWoodland-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
}
