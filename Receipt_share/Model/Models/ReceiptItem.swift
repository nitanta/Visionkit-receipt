//
//  ReceiptItem.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

import Foundation
import CoreData

class ReceiptItem: NSManagedObject, DatabaseManageable, Decodable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ReceiptItem> {
        return NSFetchRequest<ReceiptItem>(entityName: "ReceiptItem")
    }
    
    @NSManaged var id: String?
    @NSManaged var scannedDate: Date?
    @NSManaged var item: NSSet?
    
    required convenience public init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.managedObjectContext
        guard  let entity = NSEntityDescription.entity(forEntityName: "ReceiptItem", in: context) else {
            fatalError("Decode failure")
        }
        
        self.init(entity: entity, insertInto: context)
        let values = try decoder.container(keyedBy: CodingKeys.self)
                
        id = try values.decodeIfPresent(String.self, forKey: .id)
        scannedDate = try values.decodeIfPresent(Date.self, forKey: .scannedDate)
        if let items = try values.decodeIfPresent([Column].self, forKey: .item) {
            self.item = NSSet(array: items)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, scannedDate, item
    }
    
    static func save(_ id: String, scannedDate: Date, item: [Column]) -> ReceiptItem {
        
        let localItem = ReceiptItem(context: PersistenceController.shared.managedObjectContext)
        
        localItem.id = id
        localItem.scannedDate = scannedDate
        localItem.item = NSSet(array: item)
        return localItem
    }
}

extension ReceiptItem {
    var columnList: [Column] {
        if let columns = self.item?.allObjects as? [Column] {
            return columns
        }
        return []
    }
}
