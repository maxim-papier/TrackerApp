import UIKit

final class CategoryCellView: UITableViewCell {

    static let identifier = "CategoryCell"
    
    var toggleValueChanged: ((Bool) -> Void)?
    
    var categoryButtonPosition: CategoryButtonPosition = .middle {
        didSet { updateAppearance()
        }
    }

    private lazy var backgroundShape: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor.mainColorYP(.backgroundYP)
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var labelMenu: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.font = FontYP.regular17
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = UIColor.mainColorYP(.blueYP)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()

        labelMenu.text = nil
        checkmarkImageView.isHidden = true
        categoryButtonPosition = .middle
    }


    private func updateAppearance() {

        let radius: CGFloat = 16
        let inset: CGFloat = 32

        switch categoryButtonPosition {

        case .first:
            backgroundShape.layer.cornerRadius = radius
            backgroundShape.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        case .middle:
            backgroundShape.layer.maskedCorners = []
            
            separatorInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)


        case .last:
            backgroundShape.layer.cornerRadius = radius
            backgroundShape.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)


        case .single:
            backgroundShape.layer.cornerRadius = radius

            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("Old people love new Clint Eastwood movies")
    }
    
    func configure(with viewModel: CategoryCellViewModel) {
        labelMenu.text = viewModel.title
        checkmarkImageView.isHidden = !viewModel.isSelected
        LogService.shared.log("Checkmarks for the name \(viewModel.title) is selected == \(viewModel.isSelected)", level: .info)
        categoryButtonPosition = viewModel.position

        updateAppearance()
    }
}

// MARK: - Configuration

extension CategoryCellView {

    func configureLayout() {
        contentView.addSubview(backgroundShape)
        backgroundShape.addSubview(labelMenu)
        backgroundShape.addSubview(checkmarkImageView)

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
