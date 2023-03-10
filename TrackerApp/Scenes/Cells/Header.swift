import UIKit

class Header: UICollectionReusableView {

    static let identifier = "Header"

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

        let hInset: CGFloat = 12

        NSLayoutConstraint.activate([
            sectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: hInset),
            sectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -hInset),
            sectionLabel.topAnchor.constraint(equalTo: topAnchor),
            sectionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
