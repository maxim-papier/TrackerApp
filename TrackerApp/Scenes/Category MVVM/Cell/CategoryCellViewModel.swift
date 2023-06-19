import Foundation

enum CategoryButtonPosition {
    case first, middle, last, single
}

class CategoryCellViewModel {
    let title: String
    let isSelected: Bool
    var position: CategoryButtonPosition

    init(category: CategoryData, isSelected: Bool, position: CategoryButtonPosition) {
        self.title = category.name ?? ""
        self.isSelected = isSelected
        self.position = position
    }
}
