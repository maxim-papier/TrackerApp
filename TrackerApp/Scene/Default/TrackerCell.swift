import UIKit

final class TrackerCell: UICollectionViewCell {

    static let identifier = "TrackerCell"

    let backgroundShape: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let emojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.font = FontYP.medium12
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.font = FontYP.medium12
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let daysLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .colorYP(.blackYP)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = FontYP.medium12
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let doneButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .colorYP(.whiteYP)
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()


    override init(frame: CGRect) {
        super .init(frame: frame)
        super.layoutSubviews()

        contentView.addSubview(backgroundShape)
        contentView.addSubview(doneButton)
        contentView.addSubview(daysLabel)
        backgroundShape.addSubview(titleLabel)
        backgroundShape.addSubview(emojiLabel)

        NSLayoutConstraint.activate([
            backgroundShape.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundShape.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundShape.topAnchor.constraint(equalTo: contentView.topAnchor),
            // backgroundShape.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.topAnchor.constraint(equalTo: backgroundShape.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: 12),

            titleLabel.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundShape.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: backgroundShape.bottomAnchor, constant: -12),

            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -8),
            daysLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),

            doneButton.topAnchor.constraint(equalTo: backgroundShape.bottomAnchor, constant: 8),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init has not been implemented")
    }
}
