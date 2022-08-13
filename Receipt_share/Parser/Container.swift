//
//  Container.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import Foundation

class Container {
    static let jsonDecoder: JSONDecoder = JSONDecoder()
    static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
}
