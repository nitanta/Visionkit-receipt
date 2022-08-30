//
//  DatabaseManageable.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

//
//  DatabaseManageable.swift
//  Stationmaster
//
//  Created by Nitanta Adhikari on 05/07/2022.
//

import Foundation
import CoreData

protocol DatabaseManageable {
    static var database: PersistenceController { get }
    static func findFirst<T: NSManagedObject>(predicate: NSPredicate?, type: T.Type) throws -> T?
    static func findOrCreate<T: NSManagedObject>(predicate: NSPredicate?, type: T.Type) -> T
    static func remove<T: NSManagedObject>(predicate: NSPredicate?, type: T.Type)
}

extension DatabaseManageable {
    static var database: PersistenceController {
        return PersistenceController.shared
    }
    
    static func findFirst<T: NSManagedObject>(predicate: NSPredicate?, type: T.Type) -> T? {
        let request = T.fetchRequest()
        request.fetchLimit = 1
        request.predicate = predicate
        request.entity = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: database.managedObjectContext)

        do {
            guard let data = try database.managedObjectContext.fetch(request).first else { return nil }
            return data as? T
        } catch {
            return nil
        }
    }
    
    static func findAll<T: NSManagedObject>(predicate: NSPredicate?, type: T.Type) -> [T] {
        let request = T.fetchRequest()
        request.predicate = predicate
        do {
            let data = try database.managedObjectContext.fetch(request)
            return (data as? [T]) ?? []
        } catch {
            return []
        }
    }
    
    static func findOrCreate<T: NSManagedObject>(predicate: NSPredicate?, type: T.Type) -> T {
        if let item = try? Self.findFirst(predicate: predicate, type: T.self) {
            return item
        } else {
            return T(context: database.managedObjectContext)
        }
    }
    
    static func remove<T: NSManagedObject>(predicate: NSPredicate?, type: T.Type) {
        if let data = try? Self.findFirst(predicate: predicate, type: T.self) {
            Self.database.managedObjectContext.delete(data)
        }
    }
}
