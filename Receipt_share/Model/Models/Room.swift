//
//  Room.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 30/08/2022.
//

import Foundation
import CoreData
import UIKit

class Room: NSManagedObject, DatabaseManageable, Codable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }
    
    @NSManaged var id: String?
    
    @NSManaged var participants: NSSet?
    @NSManaged var selection: NSSet?
    
    required convenience public init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.managedObjectContext
        guard  let entity = NSEntityDescription.entity(forEntityName: "Room", in: context) else {
            fatalError("Decode failure")
        }
        
        self.init(entity: entity, insertInto: context)
        let values = try decoder.container(keyedBy: CodingKeys.self)
                
        id = try values.decodeIfPresent(String.self, forKey: .id)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
    }
    
    static func save(_ id: String) -> Room {
        let localItem: Room!
        if let user = findFirst(predicate: NSPredicate(format: "id == %@", id), type: Room.self) {
            localItem = user
        } else {
            localItem = Room(context: PersistenceController.shared.managedObjectContext)
        }
        
        localItem.id = id
        return localItem
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
