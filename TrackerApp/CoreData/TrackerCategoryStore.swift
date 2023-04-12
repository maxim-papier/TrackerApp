import Foundation
import CoreData

final class TrackerCategoryStore {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // Add CRUD here

    func createCategory(name: String) {

        if categoryExist(withName: name) {
            print("Category with name \(name) already exist")
        }

        let categoryData = CategoryData(context: context)
        categoryData.name = name
        categoryData.id = UUID()
        categoryData.createdAt = Date()

        do {
            try context.save()
        } catch {
            context.rollback()
            print("Failed to save new category: \(error.localizedDescription)")
        }

    }

//    func getCategory(by id: UUID) -> TrackerCategory? {
//
//        let fetchRequest: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//        fetchRequest.fetchLimit = 1
//
//        do {
//            let fetchedCategories = try context.fetch(fetchRequest)
//            return fetchedCategories.first.map(TrackerCategory.from(entity))
//        } catch {
//            <#statements#>
//        }
//
//
//    }


    //func getAllCategories() -> [TrackerCategory]




    private func categoryExist(withName name: String) -> Bool {

        let fetchRequest: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)

        do {
            let fetchedCategories = try context.fetch(fetchRequest)
            return !fetchedCategories.isEmpty
        } catch {
            print("Failed to check if category exists: \(error.localizedDescription)")
            return false
        }

    }

}
