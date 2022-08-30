//
//  User.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 30/08/2022.
//

import Foundation
import CoreData
import UIKit

class User: NSManagedObject, DatabaseManageable, Codable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    
    @NSManaged var id: String?
    @NSManaged var deviceName: String?
    @NSManaged var nickName: String?
    
    @NSManaged var selection: NSSet?
    @NSManaged var room: NSSet?
    
    required convenience public init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.managedObjectContext
        guard  let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
            fatalError("Decode failure")
        }
        
        self.init(entity: entity, insertInto: context)
        let values = try decoder.container(keyedBy: CodingKeys.self)
                
        id = try values.decodeIfPresent(String.self, forKey: .id)
        deviceName = try values.decodeIfPresent(String.self, forKey: .deviceName)
        nickName = try values.decodeIfPresent(String.self, forKey: .nickName)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(deviceName, forKey: .deviceName)
        try container.encode(nickName, forKey: .nickName)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, deviceName, nickName
    }
    
    static func save(_ id: String, deviceName: String, nickName: String) -> User {
        let localItem: User!
        if let user = findFirst(predicate: NSPredicate(format: "id == %@", id), type: User.self) {
            localItem = user
        } else {
            localItem = User(context: PersistenceController.shared.managedObjectContext)
        }
        
        localItem.id = id
        localItem.deviceName = deviceName
        localItem.nickName = nickName
        return localItem
    }
}

extension User {
    static var getDeviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    static var pdeviceName: String {
        UIDevice.current.name
    }
    
    var isMe: Bool {
        return id == User.getDeviceId
    }
    
    var displayName: String {
        return nickName ?? deviceName.safeUnwrapped
    }
    
    var roomList: [Room] {
        if let rooms = room?.allObjects as? [Room] {
            return rooms
        }
        return []
    }
    
    var selectionList: [Selection] {
        if let selections = selection?.allObjects as? [Selection] {
            return selections
        }
        return []
    }
}

