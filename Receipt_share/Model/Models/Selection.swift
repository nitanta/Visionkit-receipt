//
//  Selection.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 30/08/2022.
//

import Foundation
import CoreData
import UIKit

class Selection: NSManagedObject, DatabaseManageable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Selection> {
        return NSFetchRequest<Selection>(entityName: "Selection")
    }
    
    @NSManaged var id: String?
    @NSManaged var column: Column?
    @NSManaged var user: User?
    
    @NSManaged var room: Room?
    
    public struct Object: Codable {
        let id: String?
        let column: Column.Object?
        let user: User.Object?
    }
    
    static func createRoom(_ id: String, room: Room, column: Column) -> Selection {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", id), type: Selection.self)
        
        localItem.id = id
        localItem.column = column
        localItem.room = room
        return localItem
    }
    
    static func save(_ selection: Selection.Object) -> Selection {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", selection.id.safeUnwrapped), type: Selection.self)
        
        localItem.id = selection.id
        if let columnObject = selection.column {
            localItem.column = Column.save(columnObject)
        }
        if let userObject = selection.user {
            localItem.user = User.save(userObject)
        }
        return localItem
    }
    
    func saveUser(_ user: User) {
        self.user = user
    }
    
    func getObject() -> Selection.Object {
        Selection.Object(id: id, column: column?.getObject(), user: user?.getObject())
    }
}

extension Selection {
    static func roomPredicate(using roomId: String) -> NSPredicate {
        return NSPredicate(format: "room.id == %@", roomId)
    }
}
