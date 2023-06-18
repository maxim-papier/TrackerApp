import Foundation

class CategoryCellViewModel {
    let title: String
    let isSelected: Bool

    init(category: CategoryData, isSelected: Bool) {
        self.title = category.name ?? ""
        self.isSelected = isSelected
    }
}
