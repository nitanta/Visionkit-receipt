//
//  Columl.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

import Foundation
import CoreData

class Column: NSManagedObject, DatabaseManageable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Column> {
        return NSFetchRequest<Column>(entityName: "Column")
    }
    
    @NSManaged var id: String?
    @NSManaged var key: Int64
    @NSManaged var items: NSSet?
    
    @NSManaged var receiptItem: ReceiptItem?
    @NSManaged var selection: Column?
    
    public struct Object: Codable {
        let id: String?
        let key: Int64
        let items: [Item.Object]?
    }

    static func save(_ id: String, key: Int, items: [Item]) -> Column {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", id), type: Column.self)
        
        localItem.id = id
        localItem.key = Int64(key)
        items.forEach { item in
            item.column = localItem
        }
        
        return localItem
    }
    
    static func save(_ column: Column.Object) -> Column {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", column.id.safeUnwrapped), type: Column.self)
        
        localItem.id = column.id
        localItem.key = column.key
        if let itemsObject = column.items {
            itemsObject.forEach { itemObj in
                let item = Item.save(itemObj)
                item.column = localItem
            }
        }
        return localItem
    }
    
    func getObject() -> Column.Object {
        Column.Object(id: id, key: key, items: itemList.map { $0.getObject()} )
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

