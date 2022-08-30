//
//  Item.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

import Foundation
import CoreData
import UIKit
import Vision

class Item: NSManagedObject, DatabaseManageable, Codable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
    
    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var displayRect: DisplayRect?
    
    @NSManaged var column: Column?
    
    required convenience public init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.managedObjectContext
        guard  let entity = NSEntityDescription.entity(forEntityName: "Item", in: context) else {
            fatalError("Decode failure")
        }
        
        self.init(entity: entity, insertInto: context)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(String.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        displayRect = try values.decodeIfPresent(DisplayRect.self, forKey: .displayRect)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, displayRect
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(displayRect, forKey: .displayRect)
    }
    
    static func save(_ id: String, title: String, observation: VNRecognizedText, image: UIImage) -> Item {
        let localItem: Item!
        if let user = findFirst(predicate: NSPredicate(format: "id == %@", id), type: Item.self) {
            localItem = user
        } else {
            localItem = Item(context: PersistenceController.shared.managedObjectContext)
        }
        localItem.id = id
        localItem.title = title
        localItem.displayRect = createBoundingBoxOffSet(observation: observation, image: image)
        return localItem
    }
    
    static func copy(_ id: String, title: String, rect: DisplayRect?) -> Item {
        let localItem: Item!
        if let user = findFirst(predicate: NSPredicate(format: "id == %@", id), type: Item.self) {
            localItem = user
        } else {
            localItem = Item(context: PersistenceController.shared.managedObjectContext)
        }
        localItem.id = id
        localItem.title = title
        localItem.displayRect = rect
        return localItem
    }
    
    static func createBoundingBoxOffSet(observation: VNRecognizedText, image: UIImage) -> DisplayRect {
        let widthScale = UIScreen.main.bounds.size.width / image.size.width
        let heightScale = UIScreen.main.bounds.size.height / image.size.height
        
        let imageSize = CGSize(width: image.size.width * widthScale, height: image.size.height * heightScale)
        let imageTransform = CGAffineTransform.identity.scaledBy(x: imageSize.width, y: imageSize.height)
        
        let observationBounds = try? observation.boundingBox(for: observation.string.startIndex ..< observation.string.endIndex)
        
        let rectangle = observationBounds?.boundingBox.applying(imageTransform)
        
        let width = rectangle!.width
        let height = rectangle!.height
        
        let xaxis = rectangle!.origin.x - imageSize.width / 2 + rectangle!.width / 2
        let yaxis = -(rectangle!.origin.y - imageSize.height / 2 + rectangle!.height / 2)
        let rect = DisplayRect.save(UUID().uuidString, width: Float(width), height: Float(height), xaxis: Float(xaxis), yaxis: Float(yaxis))
        
        return rect
    }
}

extension Item {
    static func itemPredicate(using columnId: String) -> NSPredicate {
        return NSPredicate(format: "column.id == %@", columnId)
    }
}
