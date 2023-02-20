import UIKit

final class Placeholder: UIView {

    var placeholderType: PlaceholderType = .noTrackers {
        didSet {
            self.imageView.image = placeholderType.placeholder.imageView.image
            self.textLabel.text = placeholderType.placeholder.textLabel.text
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

    var placeholder: Placeholder {

        guard let defaultPlaceholder = UIImage(systemName: "aqi.medium") else { fatalError("SFSymbols image error") }

        let noSearchResultImage = getImage("placeholderNoSearchResults")
        let noTrackersImage = getImage("placeholderNoTrackers")
        let noCategoriesImage = getImage("placeholderNoTrackers")
        let noStatsImage = getImage("placeholderNoStats")

        func getImage(_ imageName: String) -> UIImage {
            return .init(named: imageName) ?? defaultPlaceholder
        }

        switch self {
        case .noSearchResults:
            return .init(image: noSearchResultImage, text: "Ничего не найдено")
        case .noTrackers:
            return .init(image: noTrackersImage, text: "Что будем отслеживать?")
        case .noCategories:
            return .init(image: noCategoriesImage, text: "Привычки и события\n можно объединить по смыслу")
        case .noStats:
            return .init(image: noStatsImage, text: "Анализировать пока нечего")
        }
    }
}

enum PlaceholderState {
    case show
    case hide
}
