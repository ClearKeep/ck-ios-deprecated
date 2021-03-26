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
                if lastMessageAt < group.lastMessageAt {
                    return
                }
                
                group.lastMessage = lastMessage
                group.lastMessageAt = lastMessageAt
                group.idLastMessage = idLastMessage
                group.updatedAt = lastMessageAt
                let realmGroup = buildRealmGroup(group: group)
                guard write(group: realmGroup) else { return }
                all[index] = group
                //                sort()
            }
        }
    }
    
    func updateTimeSyncMessageInGroup(groupID: Int64 , lastMessageAt: Int64){
        if let index = all.firstIndex(where: { $0.groupID == groupID }) {
            if var group = all.filter({$0.groupID == groupID}).first {
                group.timeSyncMessage = lastMessageAt
                let realmGroup = buildRealmGroup(group: group)
                guard write(group: realmGroup) else { return }
                all[index] = group
            }
        }
    }
    
    func getTimeSyncInGroup(groupID: Int64) -> Int64{
        
        var time: Int64 = 0
        if let group = all.filter({$0.groupID == groupID}).first {
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
                self.updateTimeSyncMessageInGroup(groupID: groupID, lastMessageAt: time)
            }
        }
        return time
    }
    
    func getDisplayNameSenderMessage(fromClientId: String , groupID: Int64) -> String{
        let group = self.filterGroup(groupId: groupID)
        let from = group?.lstClientID.filter{$0.id == fromClientId}.first
        return from?.username ?? ""
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
            if group.lstClientID.filter({$0.id == clientId}).count > 0 && group.groupType == type {
                return true
            }
            return false
        }.first
    }
    
    func filterGroup(groupId: Int64) -> GroupModel?{
        let group = self.all.filter{$0.groupID == groupId}.first
        return group
    }
    
    func registerGroup(groupId: Int64){
        if let index = all.firstIndex(where: { $0.groupID == groupId }) {
            if var group = all.filter({$0.groupID == groupId}).first {
                group.isRegister = true
                let realmGroup = buildRealmGroup(group: group)
                guard write(group: realmGroup) else { return }
                all[index] = group
            }
        }
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
                self.sort()
            }
        }
    }
    
    private func buildGroup(realmGroup: RealmGroup) -> GroupModel {
        
        var lstClientId = Array<GroupMember>()
        realmGroup.lstClientID.forEach { (member) in
            lstClientId.append(GroupMember(id: member.id, username: member.displayName))
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
                               lastMessage: realmGroup.lastMessage,
                               idLastMessage: realmGroup.idLastMsg,
                               isRegister: realmGroup.isRegister,
                               timeSyncMessage: realmGroup.timeSyncMessage)
        
        return group
    }
    
    private func buildRealmGroup(group: GroupModel) -> RealmGroup {
        let realmGroup = RealmGroup()
        realmGroup.groupId = group.groupID
        copyGroupAttributes(from: group, to: realmGroup)
        
        return realmGroup
    }
    
    private func copyGroupAttributes(from group: GroupModel, to realmGroup: RealmGroup) {
        
        var listMember = List<RealmGroupMember>()
        group.lstClientID.forEach { (member) in
            let realmMember = RealmGroupMember()
            realmMember.id = member.id
            realmMember.displayName = member.username
            listMember.append(realmMember)
        }
        
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
        realmGroup.isRegister = group.isRegister
        realmGroup.timeSyncMessage = group.timeSyncMessage
    }
    
    func sort() {
        all = all.sorted { (gr1, gr2) -> Bool in
            return gr1.updatedAt > gr2.updatedAt
        }
    }
    
}
