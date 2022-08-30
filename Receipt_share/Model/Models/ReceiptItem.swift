//
//  ReceiptItem.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

import Foundation
import CoreData

class ReceiptItem: NSManagedObject, DatabaseManageable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ReceiptItem> {
        return NSFetchRequest<ReceiptItem>(entityName: "ReceiptItem")
    }
    
    @NSManaged var id: String?
    @NSManaged var scannedDate: Date?
    @NSManaged var item: NSSet?
    
    public struct Object: Codable {
        let id: String?
        let scannedDate: Date?
        let items: [Column.Object]?
    }
    
    static func save(_ id: String, scannedDate: Date, item: [Column]) -> ReceiptItem {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", id), type: ReceiptItem.self)
        
        localItem.id = id
        localItem.scannedDate = scannedDate
        localItem.item = NSSet(array: item)
        return localItem
    }
    
    func getObject() -> ReceiptItem.Object {
        ReceiptItem.Object(id: id, scannedDate: scannedDate, items: columnList.map { $0.getObject()})
    }
}

extension ReceiptItem {
    var columnList: [Column] {
        if let columns = self.item?.allObjects as? [Column] {
            return columns
        }
        return []
    }
    
    static func getRecepeit(using id: String) -> ReceiptItem? {
        let receipt = findFirst(predicate: NSPredicate(format: "id == %@", id), type: ReceiptItem.self)
        return receipt
    }
}
