enum SchedulerButtonPosition {
    case first, middle, last, single
}


import UIKit

final class SchedulerCell: UITableViewCell {

    static let identifier = "SchedulerCell"

    var buttonPosition: SchedulerButtonPosition = .middle { didSet { updateAppearance() } }
    var toggleValueChanged: ((Bool) -> Void)?


    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
    }

    let backgroundShape: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor.mainColorYP(.backgroundYP)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let labelMenu: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = FontYP.regular17
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let toggleControl: UISwitch = {
        let control = UISwitch()
        control.onTintColor = UIColor.mainColorYP(.blueYP)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()


    private func updateAppearance() {

        let radius: CGFloat = 16

        switch buttonPosition {

        case .first:
            backgroundShape.layer.cornerRadius = radius
            backgroundShape.layer.masksToBounds = true
            backgroundShape.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

            case .middle:
            backgroundShape.layer.maskedCorners = []

        case .last:
            backgroundShape.layer.cornerRadius = radius
            backgroundShape.layer.masksToBounds = true
            backgroundShape.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

        case .single:
            backgroundShape.layer.cornerRadius = radius
            backgroundShape.layer.masksToBounds = true
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("Old people love new Clint Eastwood movies")
    }

    @objc func toggleValueChanged(_ sender: UISwitch) {
        toggleValueChanged?(sender.isOn)
    }


}

extension SchedulerCell {
    func configure() {

        toggleControl.addTarget(self, action: #selector(toggleValueChanged(_:)), for: .valueChanged)

        contentView.addSubview(backgroundShape)
        backgroundShape.addSubview(labelMenu)
        backgroundShape.addSubview(toggleControl)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)

        let hInset = CGFloat(16)
        let vInset = CGFloat(26)

        NSLayoutConstraint.activate([
            labelMenu.topAnchor.constraint(equalTo: backgroundShape.topAnchor, constant: vInset),
            labelMenu.bottomAnchor.constraint(equalTo: backgroundShape.bottomAnchor, constant: -vInset),
            labelMenu.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: hInset),
            labelMenu.trailingAnchor.constraint(equalTo: toggleControl.leadingAnchor, constant: -hInset),

            toggleControl.centerYAnchor.constraint(equalTo: backgroundShape.centerYAnchor),
            toggleControl.trailingAnchor.constraint(equalTo: backgroundShape.trailingAnchor, constant: -hInset),

            backgroundShape.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: hInset),
            backgroundShape.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -hInset),
            backgroundShape.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundShape.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
