//
//  User.swift
//  Receipt_share
//
//  Created by Nitanta Adhikari on 30/08/2022.
//

import Foundation
import CoreData
import UIKit

class User: NSManagedObject, DatabaseManageable {
    @nonobjc class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    
    @NSManaged var id: String?
    @NSManaged var deviceName: String?
    @NSManaged var nickName: String?
    
    @NSManaged var selection: NSSet?
    @NSManaged var room: NSSet?
    
    public struct Object: Codable {
        let id: String?
        let deviceName: String?
        let nickName: String?
    }
    
    static func save(_ id: String, deviceName: String, nickName: String) -> User {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", id), type: User.self)
        
        localItem.id = id
        localItem.deviceName = deviceName
        localItem.nickName = nickName
        return localItem
    }
    
    static func save(_ user: User.Object) -> User {
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", user.id.safeUnwrapped), type: User.self)
        
        localItem.id = user.id
        localItem.deviceName = user.deviceName
        localItem.nickName = user.nickName
        return localItem
    }
    
    
    func getObject() -> User.Object {
        User.Object(id: id, deviceName: deviceName, nickName: nickName)
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
        return nickName.safeUnwrapped.isEmpty ? deviceName.safeUnwrapped : nickName.safeUnwrapped
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
    
    static func getMyUser() -> User? {
        let user = findFirst(predicate: NSPredicate(format: "id == %@", Self.getDeviceId), type: User.self)
        return user
    }
}

