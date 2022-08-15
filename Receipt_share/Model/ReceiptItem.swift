//
//  ReceiptItem.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import Foundation
import UIKit
import Vision
import VisionKit

struct ReceiptItem: Identifiable, Codable, Equatable, Hashable {
    
    var id: String
    var scannedDate: Date
    var items: [Item]
    
    static func ==(lhs: ReceiptItem, rhs: ReceiptItem) -> Bool {
        return lhs.id == rhs.id
    }
    
}

struct Item: Identifiable, Codable, Equatable, Hashable {
    
    var id: String
    var title: String
    var displayRect: DisplayRect?
    
    init(title: String, observation: VNRecognizedText, image: UIImage) {
        self.id = UUID().uuidString
        self.title = title
        self.displayRect = createBoundingBoxOffSet(observation: observation, image: image)
    }
    
    
    func createBoundingBoxOffSet(observation: VNRecognizedText, image: UIImage) -> DisplayRect {
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
        let rect = DisplayRect(width: width, height: height, xaxis: xaxis, yaxis: yaxis)
        
        return rect
    }
    
    mutating func changeTitle(value: String) {
        self.title = value
    }
}

struct DisplayRect: Identifiable, Codable, Hashable {
    
    var id: String
    var width: CGFloat
    var height: CGFloat
    var xaxis: CGFloat
    var yaxis: CGFloat
    
    init(width: CGFloat, height: CGFloat, xaxis: CGFloat, yaxis: CGFloat) {
        self.id = UUID().uuidString
        self.width = width
        self.height = height
        self.xaxis = xaxis
        self.yaxis = yaxis
    }
}
