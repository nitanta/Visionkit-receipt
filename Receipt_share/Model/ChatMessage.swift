//
//  ChatMessage.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 30/08/2022.
//

import UIKit

enum MessageType: String, Codable {
    case receipt
    case roominfo
    case userinfo
    case selection
}

struct ChatMessage: Identifiable, Equatable, Codable {
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id
    }
    
    var id = UUID()
    let type: MessageType
    
    var receipt: ReceiptItem.Object?
    var receiptOwner: User.Object?
    
    var roomInfo: Room.Object?
    
    var userInfo: User.Object?
    
    var columnSelect: Selection.Object?
    
    var date = Date()
    
    init(receipt: ReceiptItem, user: User) {
        type = .receipt
        self.receipt = receipt.getObject()
        receiptOwner = user.getObject()
    }
    
    init(room: Room) {
        type = .roominfo
        roomInfo = room.getObject()
    }
    
    init(user: User) {
        type = .userinfo
        userInfo = user.getObject()
    }
    
    init(selection: Selection) {
        type = .selection
        columnSelect = selection.getObject()
    }
}
