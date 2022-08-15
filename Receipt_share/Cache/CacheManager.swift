//
//  CacheManager.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import Foundation

class CacheManager {
    var reload: (() -> ())?
    init() {}
    
    func loadRecceiptList() -> [ReceiptItem] {
        if let data = UserDefaults.standard.object(forKey: UserDefaultsKey.receiptList) as? Data {
            let decoder = Container.jsonDecoder
            if let receipts = try? decoder.decode([ReceiptItem].self, from: data) {
                return receipts
            }
        }
        return []
    }

    func addReceipt(_ receipt: ReceiptItem) {
        let receipts: Set<ReceiptItem> = Set(loadRecceiptList())
        let newList = receipts.union([receipt])
        let encoder = Container.jsonEncoder
        if let encoded = try? encoder.encode(newList) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKey.receiptList)
        }
        reload?()
    }
    
    func replaceReceipt(_ receipt: ReceiptItem) {
        var receipts = loadRecceiptList()
        if let index = receipts.firstIndex(of: receipt) {
            receipts[index] = receipt
            
            let encoder = Container.jsonEncoder
            if let encoded = try? encoder.encode(receipts) {
                UserDefaults.standard.set(encoded, forKey: UserDefaultsKey.receiptList)
            }
            reload?()
        }
    }
}
