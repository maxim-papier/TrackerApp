import UIKit

enum CategoryButtonPosition {
    case first, middle, last, single
}

final class CategoryCell: UITableViewCell {

    static let identifier = "CategoryCell"
    var toggleValueChanged: ((Bool) -> Void)?
    var categoryButtonPosition: CategoryButtonPosition = .middle {
        didSet { updateAppearance()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
    }

    let backgroundShape: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor.mainColorYP(.backgroundYP)
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let selectedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        view.layer.masksToBounds = true
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

    let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = UIColor.mainColorYP(.blueYP)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()


    private func updateAppearance() {

        let radius: CGFloat = 16

        switch categoryButtonPosition {

        case .first:
            backgroundShape.layer.cornerRadius = radius
            backgroundShape.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

            selectedView.layer.cornerRadius = radius
            selectedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        case .middle:
            backgroundShape.layer.maskedCorners = []

        case .last:
            backgroundShape.layer.cornerRadius = radius
            backgroundShape.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

            selectedView.layer.cornerRadius = radius
            selectedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        case .single:
            backgroundShape.layer.cornerRadius = radius

            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

            selectedView.layer.cornerRadius = radius
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("Old people love new Clint Eastwood movies")
    }
}

// MARK: - Configuration

extension CategoryCell {

    func configure() {
        contentView.addSubview(backgroundShape)
        backgroundShape.addSubview(labelMenu)
        backgroundShape.addSubview(checkmarkImageView)

        selectedBackgroundView = selectedView

        let hInset = CGFloat(16)
        let vInset = CGFloat(26)

        NSLayoutConstraint.activate([
            labelMenu.topAnchor.constraint(equalTo: backgroundShape.topAnchor, constant: vInset),
            labelMenu.bottomAnchor.constraint(equalTo: backgroundShape.bottomAnchor, constant: -vInset),
            labelMenu.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: hInset),
            labelMenu.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -hInset),

            checkmarkImageView.centerYAnchor.constraint(equalTo: backgroundShape.centerYAnchor),
            checkmarkImageView.trailingAnchor.constraint(equalTo: backgroundShape.trailingAnchor, constant: -hInset),

            backgroundShape.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: hInset),
            backgroundShape.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -hInset),
            backgroundShape.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundShape.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
