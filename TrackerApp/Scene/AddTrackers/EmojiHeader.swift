import UIKit

class EmojiHeader: UICollectionReusableView {

    static let identifier = "EmojiHeader"

    let sectionLabel: UILabel = {
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

        addSubview(sectionLabel)

        NSLayoutConstraint.activate([
            sectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            sectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            sectionLabel.topAnchor.constraint(equalTo: topAnchor),
            sectionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
