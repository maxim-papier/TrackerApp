import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didCompleteTracker(_ isDone: Bool, in cell: TrackerCell)
}

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "TrackerCell"
    
    var delegate: TrackerCellDelegate?
    
    var doneButtonStateChange: Bool = false {
        didSet { updateDoneButton() }
    }
    var pinStateChange: Bool = false {
        didSet {
            pinImageView.isHidden = !pinStateChange
            LogService.shared.log("Pin is in \(pinStateChange)", level: .info)
        }
    }
    
    // MARK: - Setup UI elements
    
    lazy var backgroundShape: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.font = FontYP.medium12
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "pin.fill")
        imageView.tintColor = UIColor.mainColorYP(.whiteYP)
        //imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.font = FontYP.medium12
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .mainColorYP(.blackYP)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = FontYP.medium12
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.tintColor = .mainColorYP(.whiteYP)
        button.layer.cornerRadius = 17
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        
        contentView.addSubview(backgroundShape)
        contentView.addSubview(doneButton)
        contentView.addSubview(daysLabel)
        backgroundShape.addSubview(titleLabel)
        backgroundShape.addSubview(emojiLabel)
        backgroundShape.addSubview(pinImageView)
        
        NSLayoutConstraint.activate([
            backgroundShape.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundShape.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundShape.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.topAnchor.constraint(equalTo: backgroundShape.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: 12),
            
            pinImageView.topAnchor.constraint(equalTo: backgroundShape.topAnchor, constant: 18),
            pinImageView.trailingAnchor.constraint(equalTo: backgroundShape.trailingAnchor, constant: -12),
            pinImageView.widthAnchor.constraint(equalToConstant: 12),
            pinImageView.heightAnchor.constraint(equalToConstant: 12),
            
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

// MARK: - Button state control

extension TrackerCell {
    
    func setInitialDoneButtonState(isDone: Bool) {
        doneButtonStateChange = isDone
    }
    
    private func updateDoneButton() {
        if doneButtonStateChange {
            doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            doneButton.alpha = 0.5
            
        } else {
            doneButton.setImage(UIImage(systemName: "plus"), for: .normal)
            doneButton.alpha = 1
        }
    }
    
    @objc private func doneButtonPressed() {
        let isDone = !doneButtonStateChange
        doneButtonStateChange = isDone
        delegate?.didCompleteTracker(isDone, in: self)
    }
}
