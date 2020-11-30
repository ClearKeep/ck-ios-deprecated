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
class RealmGroups: GroupChats {

    // MARK:- Persons conformance
    @Published private(set) var all = [GroupModel]()

    var allPublished: Published<[GroupModel]> { _all }
    var allPublisher: Published<[GroupModel]>.Publisher { $all }

    init() {
        loadSavedData()
    }

    func add(group: GroupModel) {
        let realmGroup = buildRealmGroup(group: group)
        guard write(group: realmGroup) else { return }
            all.append(group)
    }

    func update(group: GroupModel) {
        if let index = all.firstIndex(where: { $0.id == group.id }) {
            let realmGroup = buildRealmGroup(group: group)
            guard write(group: realmGroup) else { return }
            all[index] = group
        }
        else {
            print("group not found")
        }
    }

    func remove(groupRemove: GroupModel) {
        for (index, group) in all.enumerated() {
            if group.id == groupRemove.id {
                let realmGroup = buildRealmGroup(group: group)
                guard delete(group: realmGroup) else { continue }
                all.remove(at: index)
            }
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
                                         forPrimaryKey: group.id) {
                realm.delete(group)
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

    private func loadSavedData() {
        DispatchQueue.global().async {
            guard let realm = self.getRealm() else { return }

            let objects = realm.objects(RealmGroup.self)

            let groups: [GroupModel] = objects.map { object in
                self.buildGroup(realmGroup: object)
            }

            DispatchQueue.main.async {
                self.all = groups
            }
        }
    }

    private func buildGroup(realmGroup: RealmGroup) -> GroupModel {
        guard let id = UUID(uuidString: realmGroup.id) else {
            fatalError("Corrupted ID: \(realmGroup.id)")
        }
        
        let group = GroupModel(id: id,
                               groupID: realmGroup.groupId,
                               groupName: realmGroup.groupName,
                               groupAvatar: realmGroup.avatarGroup,
                               groupType: realmGroup.groupType,
                               createdByClientID: realmGroup.createdByClientID,
                               createdAt: realmGroup.createdAt,
                               updatedByClientID: realmGroup.updatedByClientID,
                               lstClientID: realmGroup.lstClientID,
                               updatedAt: realmGroup.updatedAt)

        return group
    }

    private func buildRealmGroup(group: GroupModel) -> RealmGroup {
        let realmGroup = RealmGroup()
        realmGroup.id = group.id.uuidString
        copyGroupAttributes(from: group, to: realmGroup)

        return realmGroup
    }

    private func copyGroupAttributes(from group: GroupModel, to realmGroup: RealmGroup) {
        realmGroup.groupName = group.groupName
        realmGroup.avatarGroup = group.groupAvatar
        realmGroup.groupType = group.groupType
        realmGroup.createdByClientID = group.createdByClientID
        realmGroup.createdAt = group.createdAt
        realmGroup.updatedByClientID = group.updatedByClientID
        realmGroup.updatedAt = group.updatedAt
        realmGroup.lstClientID.append(objectsIn: group.lstClientID)
    }

}
