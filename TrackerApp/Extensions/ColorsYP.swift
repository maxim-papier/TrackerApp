import UIKit

enum MainColorStyle: String {
    case blackYP = "black"
    case whiteYP = "white"
    case grayYP = "gray"
    case lightGrayYP = "lightGray"
    case redYP = "red"
    case blueYP = "blue"
    case backgroundYP = "background"
}

enum SelectionColorStyle: String, CaseIterable {
    case selection01 = "selection-01"
    case selection02 = "selection-02"
    case selection03 = "selection-03"
    case selection04 = "selection-04"
    case selection05 = "selection-05"
    case selection06 = "selection-06"
    case selection07 = "selection-07"
    case selection08 = "selection-08"
    case selection09 = "selection-09"
    case selection10 = "selection-10"
    case selection11 = "selection-11"
    case selection12 = "selection-12"
    case selection13 = "selection-13"
    case selection14 = "selection-14"
    case selection15 = "selection-15"
    case selection16 = "selection-16"
    case selection17 = "selection-17"
    case selection18 = "selection-18"
}

extension UIColor {
    static func mainColorYP(_ color: MainColorStyle) -> UIColor? {
        return UIColor(named: color.rawValue)
    }

    static func selectionColorYP(_ color: SelectionColorStyle) -> UIColor? {
        return UIColor(named: color.rawValue)
    }
}


// MARK: - CONVERTERS

extension UIColor {

    // HEX to String

    func toHexString() -> String {

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let redInt = Int(red * 255.0)
        let greenInt = Int(green * 255.0)
        let blueInt = Int(blue * 255.0)
        let alphaInt = Int(alpha * 255.0)

        let hexString = String(format: "#%02X%02X%02X%02X", redInt, greenInt, blueInt, alphaInt)
        return hexString.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


extension UIColor {

    // String to HEX

    convenience init(hexString: String) {

        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(after: hexString.startIndex)
        }

        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)

        let red = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
        let blue = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
        let alpha = CGFloat(hexNumber & 0x000000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
