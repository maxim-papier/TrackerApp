import Foundation

enum ButtonState {
    case add
    case ready
}

protocol CategoryViewModelDelegate: AnyObject {
    func categoryViewDidUpdate(_ viewModel: CategoryViewModel)
    func categoryViewModel(_ viewModel: CategoryViewModel, didUpdateButtonSateTo state: ButtonState)
}

final class CategoryViewModel {
    
    private var dependencies: DependencyContainer
    private var categories: [CategoryData] = []
    private var selectedCategory: CategoryData?
    
    weak var delegate: CategoryViewModelDelegate?
    
    var numberOfCategories: Int {
        return categories.count
    }
    
    var buttonState: ButtonState = .add {
        didSet {
            delegate?.categoryViewModel(self, didUpdateButtonSateTo: buttonState)
        }
    }
    
    init(dependencies: DependencyContainer) {
        self.dependencies = dependencies
    }
    
    func fetchCategories() {
        let fetchedResulstController = dependencies.fetchedResultsControllerForCategory
        categories = fetchedResulstController.fetchedObjects ?? []
        delegate?.categoryViewDidUpdate(self)
    }
    
    func cellViewModel(at indexPath: IndexPath) -> CategoryCellViewModel? {
        guard let selectedCategoryId = selectedCategory?.id else {
            return CategoryCellViewModel(category: categories[indexPath.row], isSelected: false)
        }

        let category = categories[indexPath.row]
        let isSelected = category.id == selectedCategoryId
        
        return .init(category: category, isSelected: isSelected)
    }

    func selectCategory(at indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        buttonState = selectedCategory != nil ? .ready : .add
    }
}
