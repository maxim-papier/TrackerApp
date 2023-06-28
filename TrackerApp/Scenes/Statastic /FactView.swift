import UIKit

final class StatisticsFactView: UIStackView {
    private lazy var factLabel: UILabel = {
        let label = UILabel()
        label.font = FontYP.bold34
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = FontYP.medium12
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addArrangedSubview(factLabel)
        addArrangedSubview(descriptionLabel)

        axis = .vertical
        spacing = 2
        alignment = .leading

        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)

        layer.borderWidth = 1
        layer.cornerRadius = 16
        clipsToBounds = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let gradient = UIImage.gradientImage(
            bounds: bounds,
            colors: [
                .red,
                .green,
                .systemBlue
            ])
        
        layer.borderColor = UIColor(patternImage: gradient).cgColor
    }

    func update(fact: String, description: String) {
        factLabel.text = fact
        descriptionLabel.text = description
    }
}

extension UIImage {
    static func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map(\.cgColor)

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        let renderer = UIGraphicsImageRenderer(bounds: bounds)

        return renderer.image { ctx in
            gradientLayer.render(in: ctx.cgContext)
        }
    }
}
