import UIKit

final class InputCell: UICollectionViewCell {

    static let identifier = "InputCell"

    var textFieldValueChanged: ((String) -> Void)?

    let backgroundShape: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.backgroundColor = UIColor.mainColorYP(.backgroundYP)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let userInputField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .left
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("No new tricks for an old dog!")
    }

    @objc func textFieldValueDidChange(_ sender: UITextField) {
        textFieldValueChanged?(sender.text ?? "")
    }
}

extension InputCell {

    private func setupView() {

        userInputField.addTarget(self, action: #selector(textFieldValueDidChange(_:)), for: .allEditingEvents)

        contentView.addSubview(backgroundShape)
        backgroundShape.addSubview(userInputField)

        let hInset: CGFloat = 16

        NSLayoutConstraint.activate([
            backgroundShape.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundShape.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundShape.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundShape.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            userInputField.centerYAnchor.constraint(equalTo: backgroundShape.centerYAnchor),
            userInputField.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: hInset),
            userInputField.trailingAnchor.constraint(equalTo: backgroundShape.trailingAnchor, constant: -hInset),
        ])
    }
}

