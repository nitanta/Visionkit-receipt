//
//  DatabaseManageable.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContet: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Receipt_share")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteData() {
        let manager = PersistenceController.shared
        manager.clearEntities(entities: [
            String(describing: ReceiptItem.self),
            String(describing: Column.self),
            String(describing: DisplayRect.self),
            String(describing: Item.self),
            String(describing: Selection.self),
            String(describing: Room.self),
            String(describing: User.self),
        ])
    }
    
    
    private func clearEntities(entities: [String]) {
        let context = PersistenceController.shared.managedObjectContext
        context.perform {
            do {
                try entities.forEach { (entityName) in
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                    let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try context.execute(request)
                }
                try context.save()
            } catch {
                assertionFailure("Cannot perform delete \(error)")
            }
        }
    }
}
