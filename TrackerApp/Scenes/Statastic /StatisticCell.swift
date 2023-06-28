import UIKit

final class StatisticCell: UITableViewCell {
    
    static let identifier = "StatisticCell"
    
    lazy var factLabel: UILabel = {
        let label = UILabel()
        label.font = FontYP.bold34
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = FontYP.medium12
        return label
    }()
    
    private lazy var vStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [factLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        
        stack.backgroundColor = .white
        
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        
        //stack.layer.borderWidth = 1
        stack.layer.cornerRadius = 16
        stack.clipsToBounds = true
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    private lazy var gradientView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .black
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view

    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        
        let gradient = CAGradientLayer()
        gradient.frame = contentView.bounds
        gradient.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        
        contentView.layer.addSublayer(gradient)
        contentView.addSubview(gradientView)
        gradientView.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            vStack.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 1),
            vStack.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -1),
            vStack.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 1),
            vStack.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -1)
        ])
    }
    
}
