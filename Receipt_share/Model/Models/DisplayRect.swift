//
//  DisplayRect.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

import Foundation
import CoreData

class DisplayRect: NSManagedObject, DatabaseManageable, Decodable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<DisplayRect> {
        return NSFetchRequest<DisplayRect>(entityName: "DisplayRect")
    }
    
    @NSManaged var id: String?
    @NSManaged var width: Float
    @NSManaged var height: Float
    @NSManaged var xaxis: Float
    @NSManaged var yaxis: Float
    
    required convenience public init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.managedObjectContext
        guard  let entity = NSEntityDescription.entity(forEntityName: "DisplayRect", in: context) else {
            fatalError("Decode failure")
        }
        
        self.init(entity: entity, insertInto: context)
        let values = try decoder.container(keyedBy: CodingKeys.self)
                
        id = try values.decodeIfPresent(String.self, forKey: .id)
        width = try values.decodeIfPresent(Float.self, forKey: .width) ?? 0
        height = try values.decodeIfPresent(Float.self, forKey: .height) ?? 0
        xaxis = try values.decodeIfPresent(Float.self, forKey: .xaxis) ?? 0
        yaxis = try values.decodeIfPresent(Float.self, forKey: .yaxis) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, xaxis, yaxis
    }
    
    static func save(_ id: String, width: Float, height: Float, xaxis: Float, yaxis: Float) -> DisplayRect {
        let localItem: DisplayRect!
        if let user = findFirst(predicate: NSPredicate(format: "id == %@", id), type: DisplayRect.self) {
            localItem = user
        } else {
            localItem = DisplayRect(context: PersistenceController.shared.managedObjectContext)
        }
        
        localItem.id = id
        localItem.width = width
        localItem.height = height
        localItem.xaxis = xaxis
        localItem.yaxis = yaxis
        return localItem
    }
}

