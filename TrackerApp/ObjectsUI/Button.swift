import UIKit

final class Button: UIButton {

    var tapHandler: (() -> Void)?

    init(_ fillColor: UIColor, _ textColor: UIColor, _ borderColor: UIColor,  _ borderWidth: CGFloat, _ text: String) {
        super.init(frame: .zero)

        titleLabel?.font = FontYP.medium16
        backgroundColor = fillColor
        setTitleColor(textColor, for: .normal)
        setTitle(text, for: .normal)

        layer.cornerRadius = 16
        layer.masksToBounds = true
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth

        translatesAutoresizingMaskIntoConstraints = false


        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func buttonTapped() { tapHandler?() }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum ButtonType {

    case primary(isActive: Bool)
    case secondary

    func button(withText text: String) -> Button {

        switch self {

        case .primary(let isActive):
            let fillColor = isActive ? UIColor.colorYP(.blackYP)! : UIColor.colorYP(.grayYP)!
            let textColor = UIColor.colorYP(.whiteYP)!
            let borderColor = UIColor.clear
            let borderWidth: CGFloat = 0
            return .init(fillColor, textColor, borderColor, borderWidth, text)

        case .secondary:
            let fillColor = UIColor.colorYP(.whiteYP)!
            let textColor = UIColor.colorYP(.blackYP)!
            let borderColor = textColor
            let borderWidth: CGFloat = 1
            return .init(fillColor, textColor, borderColor, borderWidth, text)
        }
    }
}
