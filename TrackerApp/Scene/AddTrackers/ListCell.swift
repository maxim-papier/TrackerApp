import UIKit

class ListCell: UICollectionViewCell {
    static let identifier = "ListCell"

    let backgroundShape: UIView = {
        let view = UIView()
        //view.layer.cornerRadius = 16
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
        let chevronImage = UIImage(systemName: "chevron.right")
        imageView.image = chevronImage
        imageView.tintColor = UIColor.mainColorYP(.blackYP)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainColorYP(.grayYP)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    required init?(coder: NSCoder) {
        fatalError("No Country for Old Men")
    }
}

extension ListCell {
    func configure() {
        contentView.addSubview(separator)
        contentView.addSubview(backgroundShape)
        backgroundShape.addSubview(labelMenu)
        backgroundShape.addSubview(accessoryImage)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)


        let hInset = CGFloat(16)
        let vInset = CGFloat(26)
        NSLayoutConstraint.activate([
            labelMenu.topAnchor.constraint(equalTo: backgroundShape.topAnchor, constant: vInset),
            labelMenu.bottomAnchor.constraint(equalTo: backgroundShape.bottomAnchor, constant: -vInset),
            labelMenu.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: hInset),
            labelMenu.trailingAnchor.constraint(equalTo: accessoryImage.leadingAnchor, constant: -hInset),

            accessoryImage.centerYAnchor.constraint(equalTo: backgroundShape.centerYAnchor),
            accessoryImage.widthAnchor.constraint(equalToConstant: 13),
            accessoryImage.heightAnchor.constraint(equalToConstant: 20),
            accessoryImage.trailingAnchor.constraint(equalTo: backgroundShape.trailingAnchor, constant: -hInset),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: hInset),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -hInset),
            separator.heightAnchor.constraint(equalToConstant: 0.5),

            backgroundShape.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundShape.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundShape.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundShape.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
