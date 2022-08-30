//
//  Selection.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 30/08/2022.
//

import Foundation
import CoreData
import UIKit

class Selection: NSManagedObject, DatabaseManageable, Codable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Selection> {
        return NSFetchRequest<Selection>(entityName: "Selection")
    }
    
    @NSManaged var id: String?
    @NSManaged var column: Column?
    @NSManaged var user: User?
    
    @NSManaged var room: Room?
    
    required convenience public init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.managedObjectContext
        guard  let entity = NSEntityDescription.entity(forEntityName: "Selection", in: context) else {
            fatalError("Decode failure")
        }
        
        self.init(entity: entity, insertInto: context)
        let values = try decoder.container(keyedBy: CodingKeys.self)
                
        id = try values.decodeIfPresent(String.self, forKey: .id)
        column = try values.decodeIfPresent(Column.self, forKey: .column)
        user = try values.decodeIfPresent(User.self, forKey: .user)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(column, forKey: .column)
        try container.encode(user, forKey: .user)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, column, user
    }
    
    static func createRoom(_ id: String, column: Column) -> Selection {
        let localItem: Selection!
        if let user = findFirst(predicate: NSPredicate(format: "id == %@", id), type: Selection.self) {
            localItem = user
        } else {
            localItem = Selection(context: PersistenceController.shared.managedObjectContext)
        }
        
        localItem.id = id
        localItem.column = column
        return localItem
    }
    
    func saveUser(_ user: User) {
        self.user = user
    }
}

extension Selection {
    static func roomPredicate(using roomId: String) -> NSPredicate {
        return NSPredicate(format: "room.id == %@", roomId)
    }
}
