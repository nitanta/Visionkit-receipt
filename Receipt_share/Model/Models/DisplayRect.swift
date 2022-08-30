//
//  DisplayRect.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

import Foundation
import CoreData

class DisplayRect: NSManagedObject, DatabaseManageable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<DisplayRect> {
        return NSFetchRequest<DisplayRect>(entityName: "DisplayRect")
    }
    
    @NSManaged var id: String?
    @NSManaged var width: Float
    @NSManaged var height: Float
    @NSManaged var xaxis: Float
    @NSManaged var yaxis: Float
    
    @NSManaged var item: Item?
    
    public struct Object: Codable {
        var id: String?
        var width: Float
        var height: Float
        var xaxis: Float
        var yaxis: Float
    }

    static func save(_ id: String, width: Float, height: Float, xaxis: Float, yaxis: Float) -> DisplayRect {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", id), type: DisplayRect.self)
        
        localItem.id = id
        localItem.width = width
        localItem.height = height
        localItem.xaxis = xaxis
        localItem.yaxis = yaxis
        return localItem
    }
    
    static func save(_ rect: DisplayRect.Object) -> DisplayRect {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", rect.id.safeUnwrapped), type: DisplayRect.self)
        
        localItem.id = rect.id
        localItem.width = rect.width
        localItem.height = rect.height
        localItem.xaxis = rect.xaxis
        localItem.yaxis = rect.yaxis
        return localItem
    }
    
    func getObject() -> DisplayRect.Object {
        DisplayRect.Object(id: id, width: width, height: height, xaxis: xaxis, yaxis: yaxis)
    }
}

