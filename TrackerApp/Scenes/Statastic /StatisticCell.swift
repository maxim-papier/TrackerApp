import UIKit

final class StatisticCell: UITableViewCell {
    
    static let identifier = "StatisticCell"
    
    lazy var factView = StatisticsFactView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupSubviews() {
        
        factView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(factView)

        let hInset: CGFloat = 16
        
        NSLayoutConstraint.activate([
            factView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: hInset),
            factView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -hInset),
            factView.topAnchor.constraint(equalTo: contentView.topAnchor),
            factView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
}
