import UIKit

struct FontYP {

    enum Style: String {
        case medium = "YSDisplay-Medium"
        case regular = "YandexSansDisplay-Regular"
        case bold = "YSDisplay-Bold"
    }

    static func font(style: Style, size: CGFloat) -> UIFont {
        return UIFont(name: style.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    static var medium10: UIFont { font(style: .medium, size: 10) }
    static var medium12: UIFont { font(style: .medium, size: 12) }
    static var medium16: UIFont { font(style: .medium, size: 16) }
    static var regular17: UIFont { font(style: .regular, size: 17) }
    static var bold19: UIFont { font(style: .bold, size: 19) }
    static var bold32: UIFont { font(style: .bold, size: 32) }
    static var bold34: UIFont { font(style: .bold, size: 34) }
}
