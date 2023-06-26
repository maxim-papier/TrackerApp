import UIKit

class EmojiCell: UICollectionViewCell {

    static let identifier = "EmojiCell"

    let backgroundShape: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 0
        view.clipsToBounds = true
        view.backgroundColor = UIColor.mainColorYP(.whiteYP)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(backgroundShape)
        backgroundShape.addSubview(emojiLabel)

        NSLayoutConstraint.activate([

            backgroundShape.widthAnchor.constraint(equalToConstant: 52),
            backgroundShape.heightAnchor.constraint(equalToConstant: 52),

            emojiLabel.widthAnchor.constraint(equalToConstant: 40),
            emojiLabel.heightAnchor.constraint(equalToConstant: 40),
            emojiLabel.centerXAnchor.constraint(equalTo: backgroundShape.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: backgroundShape.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("No more storyboards!")
    }
    
    func setSelected(_ isSelected: Bool) {
        if isSelected {
            backgroundShape.backgroundColor = UIColor.mainColorYP(.lightGrayYP)
        } else {
            backgroundShape.backgroundColor = UIColor.clear
        }
    }
}
