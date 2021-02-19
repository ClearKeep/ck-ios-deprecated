//
//  RealmGroups.swift
//  ClearKeep
//
//  Created by Seoul on 11/27/20.
//

import Foundation
import RealmSwift

/// Class should be created only once
/// (typically, initialize in SceneDelegate and inject where needed)
class RealmGroups: ObservableObject {

    // MARK:- Persons conformance
    @Published var all = [GroupModel]()

//    var allPublished: Published<[GroupModel]> { _all }
//    var allPublisher: Published<[GroupModel]>.Publisher { $all }

    init() {
        loadSavedData()
    }

    func add(group: GroupModel) {
        let realmGroup = buildRealmGroup(group: group)
        guard write(group: realmGroup) else { return }
            all.append(group)
    }

    func update(group: GroupModel) {
        if let index = all.firstIndex(where: { $0.groupID == group.groupID }) {
            let realmGroup = buildRealmGroup(group: group)
            guard write(group: realmGroup) else { return }
            all[index] = group
//            sort()
        }
        else {
            print("group not found")
        }
    }
    
    func updateLastMessage(groupID: Int64 ,lastMessage: Data , lastMessageAt: Int64 , idLastMessage: String){
        if let index = all.firstIndex(where: { $0.groupID == groupID }) {
            if var group = all.filter({$0.groupID == groupID}).first {
                group.lastMessage = lastMessage
                group.lastMessageAt = lastMessageAt
                group.idLastMessage = idLastMessage
                let realmGroup = buildRealmGroup(group: group)
                guard write(group: realmGroup) else { return }
                all[index] = group
//                sort()
            }
        }
    }

    func remove(groupRemove: GroupModel) {
        for (index, group) in all.enumerated() {
            if group.groupID == groupRemove.groupID {
                let realmGroup = buildRealmGroup(group: group)
                guard delete(group: realmGroup) else { continue }
                all.remove(at: index)
            }
        }
    }
    
    func removeAll(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            self.all.removeAll()
        }
    }

    // MARK: - Private functions
    private func write(group: RealmGroup) -> Bool {
        realmWrite { realm in
            realm.add(group, update: .modified)
        }
    }

    private func delete(group: RealmGroup) -> Bool {
        realmWrite { realm in
            if let group = realm.object(ofType: RealmGroup.self,
                                         forPrimaryKey: group.groupId) {
                realm.delete(group)
            }
        }
    }
    
    func isExistGroup(groupId: Int64) -> Bool{
        return !all.filter{$0.groupID == groupId}.isEmpty
    }
    
    func getGroup(clientId: String, type: String = "peer") -> GroupModel? {
        return all.filter{group in
            if group.lstClientID.filter{$0.id == clientId}.count > 0 && group.groupType == type {
                return true
            }
            return false
        }.first
    }
    
    func filterGroup(groupId: Int64) -> GroupModel?{
        let group = self.all.filter{$0.groupID == groupId}.first
        return group
    }

    private func realmWrite(operation: (_ realm: Realm) -> Void) -> Bool {
        guard let realm = getRealm() else { return false }

        do {
            try realm.write { operation(realm) }
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return false
        }

        return true
    }

    private func getRealm() -> Realm? {
        do {
            return try Realm()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }

    func loadSavedData() {
        DispatchQueue.global().async {
            guard let realm = self.getRealm() else { return }

            let objects = realm.objects(RealmGroup.self)

            let groups: [GroupModel] = objects.map { object in
                self.buildGroup(realmGroup: object)
            }

            DispatchQueue.main.async {
                self.all = groups
//                self.sort()
            }
        }
    }

    private func buildGroup(realmGroup: RealmGroup) -> GroupModel {
        
        var lstClientId = Array<GroupMember>()
        realmGroup.lstClientID.forEach { (str) in
            let components = str.components(separatedBy: ",")
            if components.count > 0 {
                lstClientId.append(GroupMember(id: components.first!, username: components.last!))
            }
            
        }
        
        let group = GroupModel(groupID: realmGroup.groupId,
                               groupName: realmGroup.groupName,
                               groupToken: realmGroup.groupToken,
                               groupAvatar: realmGroup.avatarGroup,
                               groupType: realmGroup.groupType,
                               createdByClientID: realmGroup.createdByClientID,
                               createdAt: realmGroup.createdAt,
                               updatedByClientID: realmGroup.updatedByClientID,
                               lstClientID: lstClientId,
                               updatedAt: realmGroup.updatedAt,
                               lastMessageAt: realmGroup.lastMessageAt,
                               lastMessage: realmGroup.lastMessage, idLastMessage: realmGroup.idLastMsg)

        return group
    }

    private func buildRealmGroup(group: GroupModel) -> RealmGroup {
        let realmGroup = RealmGroup()
        realmGroup.groupId = group.groupID
        copyGroupAttributes(from: group, to: realmGroup)

        return realmGroup
    }

    private func copyGroupAttributes(from group: GroupModel, to realmGroup: RealmGroup) {
        let listClientId = group.lstClientID.map{"\($0.id),\($0.username)"}
        realmGroup.groupName = group.groupName
        realmGroup.groupToken = group.groupToken
        realmGroup.avatarGroup = group.groupAvatar
        realmGroup.groupType = group.groupType
        realmGroup.createdByClientID = group.createdByClientID
        realmGroup.createdAt = group.createdAt
        realmGroup.updatedByClientID = group.updatedByClientID
        realmGroup.updatedAt = group.updatedAt
        realmGroup.lstClientID.append(objectsIn: listClientId)
        realmGroup.lastMessage = group.lastMessage
        realmGroup.lastMessageAt = group.lastMessageAt
    }
    
    private func sort() {
        all.sort(by: { $0.updatedAt < $1.updatedAt } )
    }

}
