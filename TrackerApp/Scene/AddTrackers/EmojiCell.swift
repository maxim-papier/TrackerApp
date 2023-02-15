import UIKit

class EmojiCell: UICollectionViewCell {

    static let identifier = "EmojiCell"

    let emojiLabel: UILabel = {
        let label = UILabel()
        // label.backgroundColor = .mainColorYP(.blackYP)
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.font = FontYP.bold32
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        super.layoutSubviews()

        contentView.addSubview(emojiLabel)

        NSLayoutConstraint.activate([
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            emojiLabel.heightAnchor.constraint(equalToConstant: 52),
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("No more storyboards!")
    }
}
