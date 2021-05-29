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
    private(set) var realmGroups: RealmGroups
    private(set) var realmMessages: RealmMessages
    
    // MARK: - Init
    private init() {
        realmGroups = RealmGroups()
        realmMessages = RealmMessages()
    }
}

// MARK: - GET
extension RealmManager {
    func getDisplayNameSenderMessage(fromClientId: String , groupID: Int64) -> String {
        let group = filterGroup(groupId: groupID)
        let user = group?.lstClientID.filter { $0.id == fromClientId }.first
        return user?.displayName ?? ""
    }
    
    func getGroupName(by groupId: Int64) -> String {
        return filterGroup(groupId: groupId)?.groupName ?? ""
    }
}

// MARK: - UPDATE & INSERT
extension RealmManager {
    func updateLastMessage(_ message: MessageModel) {
        realmMessages.add(message: message)
        realmGroups.updateLastMessage(groupID: message.groupID, lastMessage: message.message, lastMessageAt: message.createdAt, idLastMessage: message.id)
    }
}

extension RealmManager {
    func filterGroup(groupId: Int64) -> RealmGroup? {
        let group = load(listOf: RealmGroup.self, filter: NSPredicate(format: "groupId == %d", groupId))
        return group.first
    }
    
    func registerGroup(groupId: Int64) {
        if let group = filterGroup(groupId: groupId) {
            write { realm in
                group.isRegistered = true
                realm.add(group, update: .modified)
            }
        }
    }
    
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
}
