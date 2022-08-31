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

class Item: NSManagedObject, DatabaseManageable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
    
    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var displayRect: DisplayRect?
    
    @NSManaged var column: Column?
    
    public struct Object: Codable {
        var id: String?
        var title: String?
        var displayRect: DisplayRect.Object?
        
        init(id: String?, title: String?, displayRect: DisplayRect.Object?) {
            self.id = id
            self.title = title
            self.displayRect = displayRect
        }
        
        init(_ id: String?, title: String?, observation: VNRecognizedText, image: UIImage) {
            self.id = id
            self.title = title
            self.displayRect = createBoundingBoxOffSet(observation: observation, image: image)
        }
        
        func createBoundingBoxOffSet(observation: VNRecognizedText, image: UIImage) -> DisplayRect.Object {
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
            let rect = DisplayRect.Object(id: UUID().uuidString, width: Float(width), height: Float(height), xaxis: Float(xaxis), yaxis: Float(yaxis))
            
            return rect
        }
    }
    
//    static func save(_ id: String, title: String, observation: VNRecognizedText, image: UIImage) -> Item {
//        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", id), type: Item.self)
//
//        localItem.id = id
//        localItem.title = title
//        localItem.displayRect = createBoundingBoxOffSet(observation: observation, image: image)
//        return localItem
//    }
    
    static func save(_ item: Item.Object) -> Item {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", item.id.safeUnwrapped), type: Item.self)
        
        localItem.id = item.id
        localItem.title = item.title
        if let rectObject = item.displayRect {
            localItem.displayRect = DisplayRect.save(rectObject)
        }
        return localItem
    }
    
    static func copy(_ id: String, title: String, rect: DisplayRect?) -> Item {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", id), type: Item.self)

        localItem.id = id
        localItem.title = title
        localItem.displayRect = rect
        return localItem
    }
    
//    static func createBoundingBoxOffSet(observation: VNRecognizedText, image: UIImage) -> DisplayRect {
//        let widthScale = UIScreen.main.bounds.size.width / image.size.width
//        let heightScale = UIScreen.main.bounds.size.height / image.size.height
//
//        let imageSize = CGSize(width: image.size.width * widthScale, height: image.size.height * heightScale)
//        let imageTransform = CGAffineTransform.identity.scaledBy(x: imageSize.width, y: imageSize.height)
//
//        let observationBounds = try? observation.boundingBox(for: observation.string.startIndex ..< observation.string.endIndex)
//
//        let rectangle = observationBounds?.boundingBox.applying(imageTransform)
//
//        let width = rectangle!.width
//        let height = rectangle!.height
//
//        let xaxis = rectangle!.origin.x - imageSize.width / 2 + rectangle!.width / 2
//        let yaxis = -(rectangle!.origin.y - imageSize.height / 2 + rectangle!.height / 2)
//        let rect = DisplayRect.save(UUID().uuidString, width: Float(width), height: Float(height), xaxis: Float(xaxis), yaxis: Float(yaxis))
//
//        return rect
//    }
    
    func getObject() -> Item.Object {
        Item.Object(id: id, title: title, displayRect: displayRect?.getObject())
    }
}

extension Item {
    static func itemPredicate(using columnId: String) -> NSPredicate {
        return NSPredicate(format: "column.id == %@", columnId)
    }
}
