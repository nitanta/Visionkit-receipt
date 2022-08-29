//
//  StringExtension.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

import Foundation

public extension Optional where Wrapped == String {
    
    var unwrapped: String {
        guard let self = self else { assertionFailure("The value should not be empty"); return "" }
        return self
    }
    
    var safeUnwrapped: String {
        guard let self = self else { return "" }
        return self
    }
    
}
