import Foundation

enum ButtonState {
    case add
    case ready
}

final class CategoryViewModel {
    
    private var dependencies: DependencyContainer
    
    @Observable private(set) var categories: [CategoryData] = []
    @Observable private(set) var buttonState: ButtonState = .add
    @Observable private(set) var selectedCategory: CategoryData?
    
    var numberOfCategories: Int {
        return categories.count
    }
    
    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }
    
    func fetchCategories() {
        let fetchedResulstController = dependencies.fetchedResultsControllerForCategory
        categories = fetchedResulstController.fetchedObjects ?? []
    }
    
    func cellViewModel(at indexPath: IndexPath) -> CategoryCellViewModel? {
        guard let selectedCategoryId = selectedCategory?.id else {
            let position = getCategoryButtonPosition(for: indexPath.row)
            return CategoryCellViewModel(category: categories[indexPath.row], isSelected: false, position: position)
        }
        
        let category = categories[indexPath.row]
        let isSelected = category.id == selectedCategoryId
        let position = getCategoryButtonPosition(for: indexPath.row)
        
        return .init(category: category, isSelected: isSelected, position: position)
    }
    
    private func getCategoryButtonPosition(for index: Int) -> CategoryButtonPosition {
        switch index {
        case 0 where categories.count == 1: return .single
        case 0: return .first
        case categories.count - 1: return .last
        default: return .middle
        }
    }
    
    func selectCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        
        if selectedCategory?.id == category.id {
            selectedCategory = nil
            buttonState = .add
        } else {
            selectedCategory = category
            buttonState = .ready
        }
    }
    
    func selectCategory(withId id: UUID) {
        guard let index = categories.firstIndex(where: { $0.id == id }) else { return }
        
        let category = categories[index]
        
        selectedCategory = category
        buttonState = .ready
        }
}
