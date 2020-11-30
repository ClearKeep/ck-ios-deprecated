//
//  RealmGroup.swift
//  ClearKeep
//
//  Created by Seoul on 11/27/20.
//

import Foundation
import RealmSwift

class RealmGroup: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var groupId: String = ""
    @objc dynamic var groupName: String = ""
    @objc dynamic var avatarGroup: String = ""
    @objc dynamic var groupType: String = ""
    var lstClientID = List<String>()
    @objc dynamic var lastMessage = MessageGroup()
    @objc dynamic var lastMessageAt: Int64 = 0
    @objc dynamic var createdByClientID: String = ""
    @objc dynamic var createdAt: Int64 = 0
    @objc dynamic var updatedByClientID: String = ""
    @objc dynamic var updatedAt: Int64 = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class MessageGroup: Object{
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var groupID: String = String()
    @objc dynamic var groupType: String = String()
    @objc dynamic var fromClientID: String = String()
    @objc dynamic var clientID: String = String()
    @objc dynamic var message = Data()
    @objc dynamic var createdAt: Int64 = 0
    @objc dynamic var updatedAt: Int64 = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
 
}
