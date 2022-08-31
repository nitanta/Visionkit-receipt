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
    @NSManaged var room: Room?
    
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
    
    static func saveRoomUser(_ user: User.Object, roomId: String) -> User {
        let newId = getParticipantId(user.id.safeUnwrapped, roomId: roomId)
        let localItem = findOrCreate(predicate: NSPredicate(format: "id == %@", newId), type: User.self)
        
        localItem.id = newId
        localItem.deviceName = user.deviceName
        localItem.nickName = user.nickName
        
        if let room = Room.findFirst(predicate: NSPredicate(format: "id == %@", roomId), type: Room.self) {
            localItem.room = room
        }
        
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
    
    static func getParticipantId(_ userId: String, roomId: String) -> String {
        return "\(userId)@\(roomId)"
    }
    
    var getUserId: String {
        if let split = id.safeUnwrapped.split(separator: "@").first {
            return String(split)
        }
        return id.safeUnwrapped
    }
    
    var getRoomId: String {
        if let split = id.safeUnwrapped.split(separator: "@").last {
            return String(split)
        }
        return id.safeUnwrapped
    }
}

