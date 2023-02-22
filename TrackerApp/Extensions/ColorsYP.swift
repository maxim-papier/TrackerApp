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
