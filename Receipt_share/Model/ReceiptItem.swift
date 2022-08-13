//
//  ReceiptItem.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import Foundation
import UIKit

struct ReceiptItem: Identifiable, CustomStringConvertible, Codable, Hashable {
    var id: String {
        return UUID().uuidString
    }
    
    var scannedDate: Date
    var items: [Item]
    
    var description: String {
        return items.description
    }
}

struct Item: Identifiable, CustomStringConvertible, Codable, Hashable {
    var id: String {
        return UUID().uuidString
    }
    var title: String
    private var boundingBox: [CGFloat]
    private var parentSize: [CGFloat]
    
    init(title: String, boundingBox: CGRect, parentSize: CGSize) {
        self.title = title
        self.boundingBox = [boundingBox.origin.x, boundingBox.origin.y, boundingBox.size.width, boundingBox.size.height]
        self.parentSize = [parentSize.width, parentSize.height]
    }
    
    var bound: CGRect {
        return CGRect(x: boundingBox[0], y: boundingBox[1], width: boundingBox[2], height: boundingBox[3])
    }
    
    var parent: CGSize {
        return CGSize(width: parentSize[0], height: parentSize[1])
    }
    
    var position: CGRect {
        let size = CGSize(width: bound.width * parent.width,
                          height: bound.height * parent.height)
        
        let origin = CGPoint(x: bound.minX * parent.width,
                             y: (1 - bound.minY) * parent.height - size.height)
                
        return CGRect(origin: origin, size: size)
    }
    
    var scale: CGFloat {
        return UIScreen.main.bounds.size.width / parent.width
    }
    
    var description: String {
        return "\(title) at position: \(position)"
    }
}
