import UIKit

final class Placeholder: UIView {

    var placeholderType: PlaceholderType = .noTrackers {
        didSet {
            self.imageView.image = placeholderType.reasonImage
            self.textLabel.text = placeholderType.reasonTitle
        }
    }

    let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    let textLabel: UILabel = {
        let label = UILabel()
        label.font = FontYP.medium12
        label.textColor = .mainColorYP(.blackYP)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(image: UIImage, text: String) {
        super.init(frame: .zero)
        self.imageView.image = image
        self.textLabel.text = text

        let stack = UIStackView()

        self.addSubview(stack)

        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 8

        stack.addArrangedSubview(self.imageView)
        stack.addArrangedSubview(self.textLabel)

        stack.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum PlaceholderType {

    case noSearchResults
    case noTrackers
    case noCategories
    case noStats

    var reasonImage: UIImage {
        guard let defaultPlaceholder = UIImage(systemName: "aqi.medium") else { fatalError("SFSymbols image error") }

        switch self {
        case .noSearchResults: return .init(named: "placeholderNoSearchResults") ?? defaultPlaceholder
        case .noTrackers: return .init(named: "placeholderNoTrackers") ?? defaultPlaceholder
        case .noCategories: return .init(named: "placeholderNoTrackers") ?? defaultPlaceholder
        case .noStats: return .init(named: "placeholderNoStats") ?? defaultPlaceholder
        }
    }

    var reasonTitle: String {

        switch self {
        case .noSearchResults: return "Ничего не найдено"
        case .noTrackers: return "Что будем отслеживать?"
        case .noCategories: return "Привычки и события\n можно объединить по смыслу"
        case .noStats: return "Анализировать пока нечего"
        }
    }

    var placeholder: Placeholder {
        return .init(image: reasonImage, text: reasonTitle)
    }
}
