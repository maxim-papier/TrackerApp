import UIKit

final class TrackerHeader: UICollectionReusableView {

    static let identifier = "TrackerHeader"

    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mainColorYP(.blackYP)
        label.font = FontYP.bold19
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(categoryLabel)

        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            categoryLabel.topAnchor.constraint(equalTo: topAnchor),
            categoryLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
