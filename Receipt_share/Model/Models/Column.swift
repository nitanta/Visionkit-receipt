//
//  Columl.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

import Foundation
import CoreData

class Column: NSManagedObject, DatabaseManageable, Codable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Column> {
        return NSFetchRequest<Column>(entityName: "Column")
    }
    
    @NSManaged var id: String?
    @NSManaged var key: Int64
    @NSManaged var items: NSSet?
    
    @NSManaged var receiptItem: ReceiptItem?
    @NSManaged var selection: Column?
    
    required convenience public init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.managedObjectContext
        guard  let entity = NSEntityDescription.entity(forEntityName: "Column", in: context) else {
            fatalError("Decode failure")
        }
        
        self.init(entity: entity, insertInto: context)
        let values = try decoder.container(keyedBy: CodingKeys.self)
                
        id = try values.decodeIfPresent(String.self, forKey: .id)
        if let items = try values.decodeIfPresent([Item].self, forKey: .items) {
            self.items = NSSet(array: items)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, key, items
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(key, forKey: .key)
        try container.encode(items as! Set<Item>, forKey: .items)
    }
    
    static func save(_ id: String, key: Int, items: [Item]) -> Column {
        let localItem: Column!
        if let user = findFirst(predicate: NSPredicate(format: "id == %@", id), type: Column.self) {
            localItem = user
        } else {
            localItem = Column(context: PersistenceController.shared.managedObjectContext)
        }
        
        localItem.id = id
        localItem.key = Int64(key)
        localItem.items = NSSet(array: items)
        return localItem
    }
}

extension Column {
    var itemList: [Item] {
        if let items = self.items?.allObjects as? [Item] {
            return items.sorted { $0.displayRect?.xaxis ?? 0 < $1.displayRect?.xaxis ?? 0}
        }
        return []
    }
    
    static func columnPredicate(using recepientId: String) -> NSPredicate {
        return NSPredicate(format: "receiptItem.id == %@", recepientId)
    }
}

