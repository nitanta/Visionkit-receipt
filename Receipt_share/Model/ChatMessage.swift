//
//  ChatMessage.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 30/08/2022.
//

import UIKit

enum MessageType: String, Codable {
    case receipt
    case userinfo
    case selection
}

struct ChatMessage: Identifiable, Equatable, Codable {
    
    var id = UUID()
    let type: MessageType
    
    var receipt: ReceiptItem?
    var receiptOwner: User?
    
    var userInfo: User?
    
    var columnSelect: Column?
    var columnSelectUser: User?
    
    init(receipt: ReceiptItem, user: User) {
        type = .receipt
        self.receipt = receipt
        receiptOwner = user
    }
    
    init(user: User) {
        type = .userinfo
        userInfo = user
    }
    
    init(column: Column, user: User) {
        type = .selection
        columnSelect = column
        columnSelectUser = user
    }
}
