import UIKit

class Button: UIButton {

    var tapHandler: (() -> Void)

    var isActive: Bool = true {
        didSet { didSetButtonActivityAndStyle(isActive: isActive) }
    }

    init(type: TypeOfButton, title: String, tapHandler: @escaping (() -> Void) = { } ) {
        self.tapHandler = tapHandler
        super.init(frame: .zero)
        setTitle(title, for: .normal)

        switch type {

        case .primary(let isActive):
            self.isActive = isActive
            setTitleColor(.white, for: .normal)
            backgroundColor = isActive ? UIColor.mainColorYP(.blackYP) : UIColor.mainColorYP(.grayYP)
            layer.borderColor = backgroundColor!.cgColor

        case .cancel:
            setTitleColor(UIColor.mainColorYP(.redYP), for: .normal)
            backgroundColor = .white
            isEnabled = true
            layer.borderColor = UIColor.mainColorYP(.redYP)!.cgColor
        }

        layer.cornerRadius = 16
        layer.borderWidth = 1

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonTapped() {
        tapHandler()
    }
}

extension Button {

    private func didSetButtonActivityAndStyle(isActive: Bool) {
        let backgroundColor = isActive ? UIColor.mainColorYP(.blackYP) : UIColor.mainColorYP(.grayYP)
        self.backgroundColor = backgroundColor
        layer.borderColor = backgroundColor!.cgColor
        isEnabled = isActive
    }
}

enum TypeOfButton {
    case primary(isActive: Bool)
    case cancel
}
