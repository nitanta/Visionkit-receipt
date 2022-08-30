//
//  Room.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 30/08/2022.
//

import Foundation
import CoreData
import UIKit

class Room: NSManagedObject, DatabaseManageable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }
    
    @NSManaged var id: String?
    @NSManaged var selection: NSSet?
    
    @NSManaged var participants: NSSet?
    
    public struct Object: Codable {
        let id: String?
        let selection: [Selection.Object]?
    }

    func addSelections(_ columns: [Column], room: Room) {
        columns.forEach { column in
            _ = Selection.createRoom(column.id.safeUnwrapped, room: room, column: column)
        }
    }
    
    static func save(_ id: String) -> Room {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", id), type: Room.self)

        localItem.id = id
        return localItem
    }
    
    static func save(_ room: Room.Object) -> Room {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", room.id.safeUnwrapped), type: Room.self)
        
        localItem.id = room.id
        if let selectionObject = room.selection {
            localItem.selection = NSSet(array: selectionObject.map { Selection.save($0) })
        }
        return localItem
    }
    
    func getObject() -> Room.Object {
        Room.Object(id: id, selection: selectionList.map { $0.getObject()} )
    }
}

extension Room {
    var participantsList: [User] {
        if let users = participants?.allObjects as? [User] {
            return users
        }
        return []
    }
    
    var selectionList: [Selection] {
        if let selections = selection?.allObjects as? [Selection] {
            return selections
        }
        return []
    }
}
