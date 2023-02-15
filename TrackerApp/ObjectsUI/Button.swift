import UIKit

final class Button: UIButton {

    var tapHandler: (() -> Void) = { }

    init(
        _ fillColor: UIColor,
        _ textColor: UIColor,
        _ borderColor: UIColor,
        _ borderWidth: CGFloat,
        _ text: String,
        _ tapHandler: @escaping (() -> Void) = { }
    ){

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

        self.tapHandler = tapHandler
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func buttonTapped() {
        tapHandler()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum ButtonType {

    case primary(isActive: Bool)
    case secondary

    func button(withText text: String, tapHandler: @escaping (() -> Void) = { } ) -> Button {

        switch self {

        case .primary(let isActive):
            let fillColor = isActive ? UIColor.mainColorYP(.blackYP)! : UIColor.mainColorYP(.grayYP)!
            let textColor = UIColor.mainColorYP(.whiteYP)!
            let borderColor = UIColor.clear
            let borderWidth: CGFloat = 0
            return Button(fillColor, textColor, borderColor, borderWidth, text, tapHandler)

        case .secondary:
            let fillColor = UIColor.mainColorYP(.whiteYP)!
            let textColor = UIColor.mainColorYP(.blackYP)!
            let borderColor = textColor
            let borderWidth: CGFloat = 1
            return Button(fillColor, textColor, borderColor, borderWidth, text, tapHandler)
        }
    }
}
