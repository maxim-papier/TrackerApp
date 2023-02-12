import UIKit


class Placeholder: UIView {

    let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    let textLabel: UILabel = {
        let label = UILabel()
        label.font = FontYP.medium12
        label.textColor = .colorYP(.blackYP)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(image: UIImage, text: String) {
        super.init(frame: .zero)

        self.imageView.image = image
        self.textLabel.text = text

        let stack = UIStackView()
        stack.alignment = .center
        stack.axis = .vertical
        stack.spacing = 8

        stack.addSubview(self.imageView)
        stack.addSubview(self.textLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
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
            return .init(image: noCategoriesImage, text: "Привычки и события можно объединить по смыслу")
        case .noStats:
            return .init(image: noStatsImage, text: "Анализировать пока нечего")
        }
    }
}


