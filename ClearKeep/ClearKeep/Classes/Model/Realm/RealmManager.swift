//
//  RealmManager.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/24/21.
//

import Foundation
import RealmSwift
class RealmManager {
    
    // MARK: - Singleton
    static let shared = RealmManager()
//    private(set) var realmGroups: RealmGroups
//    private(set) var realmMessages: RealmMessages
    
    // MARK: - Init
    private init() {
//        realmGroups = RealmGroups()
//        realmMessages = RealmMessages()
    }
}

// MARK: - GET
extension RealmManager {
    func getSenderName(fromClientId: String , groupId: Int64) -> String {
        let group = getGroup(by: groupId)
        let user = group?.lstClientID.filter { $0.id == fromClientId }.first
        return user?.displayName ?? ""
    }
    
    func getGroupName(by groupId: Int64) -> String {
        return getGroup(by: groupId)?.groupName ?? ""
    }
}

// MARK: - UPDATE & INSERT
// Message
extension RealmManager {
    func getAllMessageInGroup(by groupId: Int64) -> [RealmMessage] {
        return load(listOf: RealmMessage.self, filter: NSPredicate(format: "groupID == %d", groupId))
    }
    
    func isExistedMessageInGroup(by messageId: String, groupId: Int64) -> Bool {
        return load(listOf: RealmMessage.self, filter: NSPredicate(format: "groupID == %d && id = %@", groupId, messageId)).count > 0
    }
    
    func updateLastMessage(_ message: MessageModel) {
        write { realm in
            let realmMessage = RealmMessage()
            realmMessage.id = message.id
            realmMessage.groupID = message.groupID
            realmMessage.groupType = message.groupType
            realmMessage.fromClientID = message.fromClientID
            realmMessage.clientID = message.clientID
            realmMessage.message = message.message
            realmMessage.createdAt = message.createdAt
            realmMessage.updatedAt = message.updatedAt
            
            realm.add(realmMessage, update: .modified)
        }
        updateLastMessageToGroup(groupId: message.groupID, lastMessage: message.message, lastMessageAt: message.createdAt, idLastMessage: message.id)
    }
    
    func updateLastMessageToGroup(groupId: Int64, lastMessage: Data, lastMessageAt: Int64, idLastMessage: String) {
        if let group = getGroup(by: groupId) {
            if lastMessageAt < group.lastMessageAt {
                return
            }
            
            write { realm in
                group.lastMessage = lastMessage
                group.lastMessageAt = lastMessageAt
                group.idLastMsg = idLastMessage
                group.updatedAt = lastMessageAt
                realm.add(group, update: .modified)
            }
        }
    }
}

// Group
extension RealmManager {
    func addAndUpdateGroup(group: GroupModel, completion: () -> ()) {
        write { realm in
            let realmGroup = RealmGroup()
            let listMember = List<RealmGroupMember>()
            group.lstClientID.forEach { (member) in
                let realmMember = RealmGroupMember()
                realmMember.id = member.id
                realmMember.displayName = member.username
                listMember.append(realmMember)
            }
            realmGroup.groupId = group.groupID
            realmGroup.groupName = group.groupName
            realmGroup.groupToken = group.groupToken
            realmGroup.avatarGroup = group.groupAvatar
            realmGroup.groupType = group.groupType
            realmGroup.createdByClientID = group.createdByClientID
            realmGroup.createdAt = group.createdAt
            realmGroup.updatedByClientID = group.updatedByClientID
            realmGroup.updatedAt = group.updatedAt
            realmGroup.lstClientID = listMember
            realmGroup.lastMessage = group.lastMessage
            realmGroup.idLastMsg = group.idLastMessage
            realmGroup.lastMessageAt = group.lastMessageAt
            realmGroup.isRegistered = group.isRegistered
            realmGroup.timeSyncMessage = group.timeSyncMessage
            
            realm.add(realmGroup, update: .modified)
            completion()
        }
    }
    
    func getAllGroups() -> [RealmGroup] {
        return load(listOf: RealmGroup.self)
    }
    
    func getGroup(by clientId: String, type: String) -> RealmGroup? {
        let groups = load(listOf: RealmGroup.self, filter: NSPredicate(format: "groupType == %@", type))
        let group = groups.filter { group in
            if group.lstClientID.filter({$0.id == clientId}).count > 0 {
                return true
            }
            return false
        }.first
        return group
    }
    
    func getGroup(by groupId: Int64) -> RealmGroup? {
        let group = load(listOf: RealmGroup.self, filter: NSPredicate(format: "groupId == %d", groupId))
        return group.first
    }
    
    func registerGroup(by groupId: Int64) {
        if let group = getGroup(by: groupId) {
            write { realm in
                group.isRegistered = true
                realm.add(group, update: .modified)
            }
        }
    }
    
    func updateTimeSyncMessageInGroup(groupId: Int64 , lastMessageAt: Int64){
        if let group = getGroup(by: groupId) {
            write({ realm in
                group.timeSyncMessage = lastMessageAt
                realm.add(group, update: .modified)
            })
        }
    }
    
    func getTimeSyncInGroup(groupId: Int64) -> Int64{
        var time: Int64 = 0
        if let group = getGroup(by: groupId) {
            time = group.timeSyncMessage
        }
        if let loginDate = UserDefaults.standard.value(forKey: Constants.User.loginDate) as? Date {

            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar.current
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                        
            let updateAt = NSDate(timeIntervalSince1970: TimeInterval(time/1000))
            if loginDate.compare(updateAt as Date) == ComparisonResult.orderedDescending {
                time = Int64(loginDate.timeIntervalSince1970) * 1000
                updateTimeSyncMessageInGroup(groupId: groupId, lastMessageAt: time)
            }
        }
        return time
    }
}

extension RealmManager {
    private func write(_ handler: ((_ realm: Realm) -> Void)) {
        do {
            let realm = try Realm()
            try realm.write {
                handler(realm)
            }
        } catch { }
    }
    
    private func load<T: Object>(listOf: T.Type, filter: NSPredicate? = nil) -> [T] {
        do {
            var objects = try Realm().objects(T.self)
            if let filter = filter {
                objects = objects.filter(filter)
            }
            var list = [T]()
            for obj in objects {
                list.append(obj)
            }
            return list
        } catch { }
        return []
    }
    
    func removeAll() {
        write { realm in
            realm.deleteAll()
        }
    }
}
