import UIKit

final class TrackerCell: UICollectionViewCell {

    static let identifier = "TrackerCell"

    var delegate: TrackerCellDelegate?

    func setInitialDoneButtonState(isDone: Bool) {
        doneButtonStateChange = isDone
    }

    var doneButtonStateChange: Bool = false {
        didSet { updateDoneButton() }
    }

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
        label.textColor = .mainColorYP(.blackYP)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = FontYP.medium12
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let doneButton: UIButton = {
        let button = UIButton()
        button.tintColor = .mainColorYP(.whiteYP)
        button.layer.cornerRadius = 17
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private func updateDoneButton() {
        if doneButtonStateChange {
            doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            doneButton.alpha = 0.5

        } else {
            doneButton.setImage(UIImage(systemName: "plus"), for: .normal)
            doneButton.alpha = 1
        }
    }

    @objc func doneButtonPressed() {
        let isDone = !doneButtonStateChange
        doneButtonStateChange = isDone
        delegate?.didCompleteTracker(isDone, in: self)
    }


    override init(frame: CGRect) {
        super.init(frame: frame)


        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)

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

protocol TrackerCellDelegate: AnyObject {
    func didCompleteTracker(_ isDone: Bool, in cell: TrackerCell)
}
