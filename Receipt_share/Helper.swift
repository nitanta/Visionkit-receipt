//
//  Helper.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 29/08/2022.
//

import Foundation
import UIKit

class Helpers {
    
    static func printAppfonts() {
        for font in UIFont.familyNames {
            debugPrint(UIFont.fontNames(forFamilyName: font))
        }
    }
    
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var getFilePath: String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return "FILE PATH: \(paths[0])"
    }
   
    
    static func valid(string: String, with regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@ ", regex)
        return predicate.evaluate(with: string)
    }
}
