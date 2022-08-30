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
    
    var id = UUID()
    let type: MessageType
    
    var receipt: ReceiptItem?
    var receiptOwner: User?
    
    var roomInfo: Room?
    
    var userInfo: User?
    
    var columnSelect: Selection?
    
    var date = Date()
    
    init(receipt: ReceiptItem, user: User) {
        type = .receipt
        self.receipt = receipt
        receiptOwner = user
    }
    
    init(room: Room) {
        type = .roominfo
        roomInfo = room
    }
    
    init(user: User) {
        type = .userinfo
        userInfo = user
    }
    
    init(selection: Selection) {
        type = .selection
        columnSelect = selection
    }
}
