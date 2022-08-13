//
//  DocumentManager.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 13/08/2022.
//

import Foundation
import UIKit

class DocumentManager {
    init() {}
    
    var fileManagerPath: NSURL? {
        return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL
    }
    
    func saveImage(image: UIImage, id: String) {
        guard let directory = fileManagerPath, let data = image.jpegData(compressionQuality: 1.0) else { return }
        do {
            try data.write(to: directory.appendingPathComponent("\(id).jpeg")!)
        } catch {
            print(error.localizedDescription)
        }
    }

    func loadImage(id: String) -> UIImage? {
        guard let directory = fileManagerPath, let directoryPath = directory.absoluteString else { return nil }
        let fileName = "\(id).jpeg"
        return UIImage(contentsOfFile: URL(fileURLWithPath: directoryPath).appendingPathComponent(fileName).path)
    }
}
