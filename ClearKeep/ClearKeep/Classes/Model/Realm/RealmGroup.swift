//
//  RealmGroup.swift
//  ClearKeep
//
//  Created by Seoul on 11/27/20.
//

import Foundation
import RealmSwift
    
class RealmGroup: Object {
    @objc dynamic var groupId: Int64 = 0
    @objc dynamic var groupName: String = ""
    @objc dynamic var groupToken: String = ""
    @objc dynamic var avatarGroup: String = ""
    @objc dynamic var groupType: String = ""
    var lstClientID = List<RealmGroupMember>()
    @objc dynamic var lastMessage = Data()
    @objc dynamic var lastMessageAt: Int64 = 0
    @objc dynamic var createdByClientID: String = ""
    @objc dynamic var createdAt: Int64 = 0
    @objc dynamic var updatedByClientID: String = ""
    @objc dynamic var updatedAt: Int64 = 0
    @objc dynamic var idLastMsg: String = ""
    @objc dynamic var isRegistered: Bool = false
    @objc dynamic var timeSyncMessage: Int64 = 0
    
    override class func primaryKey() -> String? {
        return "groupId"
    }
}

class RealmGroupMember: Object {
    @objc dynamic var id : String = ""
    @objc dynamic var displayName : String = ""
    @objc dynamic var workspaceDomain: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class DeviceIdForClientId: Object {
    @objc dynamic var clientId: String = ""
    @objc dynamic var recipient: Int32 = 0
    
    override class func primaryKey() -> String? {
        return "clientId"
    }
}

