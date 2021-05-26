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

extension RealmManager {
    
    func getDisplayNameSenderMessage(fromClientId: String , groupID: Int64) -> String {
        do {
            let realm = try Realm()
            let objects = realm.objects(RealmGroup.self)
            let group = objects.filter { $0.groupId == groupID }.first
            let user = group?.lstClientID.filter { $0.id == fromClientId }.first
            return user?.displayName ?? ""
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return ""
        }
    }
    
    func getGroupName(by groupID: Int64) -> String {
        do {
            let realm = try Realm()
            let objects = realm.objects(RealmGroup.self)
            let group = objects.filter { $0.groupId == groupID }.first
            
            return group?.groupName ?? ""
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return ""
        }
    }
}
