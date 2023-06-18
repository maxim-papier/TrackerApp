import Foundation

final class CategoryViewModel {
    
    private let stores: DependencyContainer
    private var categories: [Category] = []
    
    init(stores: DependencyContainer) {
        self.stores = stores
    }
    
}
