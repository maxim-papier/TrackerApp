import UIKit

final class CategoryCellView: UITableViewCell {
    
    static let identifier = "CategoryCell"
    
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
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "checkmarkIcon")
        imageView.tintColor = UIColor.mainColorYP(.blueYP)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [labelMenu, checkmarkImageView])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var customSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainColorYP(.grayYP)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        labelMenu.text = nil
        checkmarkImageView.isHidden = true
        categoryButtonPosition = .single
        
    }
    
    private func updateAppearance() {
        let radius: CGFloat = 16
        
        switch categoryButtonPosition {
        case .first:
            backgroundShape.layer.cornerRadius = radius
            backgroundShape.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            customSeparator.isHidden = false
        case .middle:
            backgroundShape.layer.cornerRadius = 0
            backgroundShape.layer.maskedCorners = []
            customSeparator.isHidden = false
        case .last:
            backgroundShape.layer.cornerRadius = radius
            backgroundShape.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            customSeparator.isHidden = true
        case .single:
            backgroundShape.layer.cornerRadius = radius
            customSeparator.isHidden = true
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
        categoryButtonPosition = viewModel.position
        updateAppearance()
    }
}

// MARK: - Configuration

extension CategoryCellView {
    
    func configureLayout() {
        contentView.addSubview(backgroundShape)
        backgroundShape.addSubview(hStack)
        backgroundShape.addSubview(customSeparator)
        
        let hInset = CGFloat(16)
        let vInset = CGFloat(26)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            hStack.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: hInset),
            hStack.trailingAnchor.constraint(equalTo: backgroundShape.trailingAnchor, constant: -hInset),
            hStack.centerYAnchor.constraint(equalTo: backgroundShape.centerYAnchor),
            
            backgroundShape.heightAnchor.constraint(equalToConstant: 75),
            backgroundShape.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: hInset),
            backgroundShape.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -hInset),
            backgroundShape.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundShape.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            customSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            customSeparator.leadingAnchor.constraint(equalTo: backgroundShape.leadingAnchor, constant: hInset),
            customSeparator.trailingAnchor.constraint(equalTo: backgroundShape.trailingAnchor, constant: -hInset),
            customSeparator.bottomAnchor.constraint(equalTo: backgroundShape.bottomAnchor)
        ])
    }
}
