enum SchedulerButtonPosition {
    case first, middle, last, single
}


import UIKit

final class SchedulerCell: UITableViewCell {

    static let identifier = "SchedulerCell"

    var buttonPosition: SchedulerButtonPosition = .middle {
        didSet { updateAppearance() }
    }

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

    let accessoryImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let toggleView: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = UIColor.mainColorYP(.blueYP)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()


    private func updateAppearance() {



        switch buttonPosition {
        case .first:
            backgroundShape.layer.cornerRadius = 16
            backgroundShape.layer.masksToBounds = true
            backgroundShape.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .middle:
            backgroundShape.layer.maskedCorners = []
        case .last:
            backgroundShape.layer.cornerRadius = 16
            backgroundShape.layer.masksToBounds = true
            backgroundShape.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

        case .single:
            backgroundShape.layer.cornerRadius = 16
            backgroundShape.layer.masksToBounds = true
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("Old folks")
    }
}

extension SchedulerCell {
    func configure() {
        contentView.addSubview(backgroundShape)
        backgroundShape.addSubview(labelMenu)
        backgroundShape.addSubview(toggleView)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)

        let hInset = CGFloat(16)
        let vInset = CGFloat(26)

        NSLayoutConstraint.activate([
            labelMenu.topAnchor.constraint(equalTo: backgroundShape.topAnchor, constant: vInset),
            labelMenu.bottomAnchor.constraint(equalTo: backgroundShape.bottomAnchor, constant: -vInset),
            labelMenu.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: hInset),
            labelMenu.trailingAnchor.constraint(equalTo: toggleView.leadingAnchor, constant: -hInset),

            toggleView.centerYAnchor.constraint(equalTo: backgroundShape.centerYAnchor),
            toggleView.trailingAnchor.constraint(equalTo: backgroundShape.trailingAnchor, constant: -hInset),

            backgroundShape.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: hInset),
            backgroundShape.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -hInset),
            backgroundShape.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundShape.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
