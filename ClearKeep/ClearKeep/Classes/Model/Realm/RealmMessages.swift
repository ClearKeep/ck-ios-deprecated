//
//  RealmMessages.swift
//  ClearKeep
//
//  Created by Seoul on 11/30/20.
//

import Foundation
import RealmSwift

/// Class should be created only once
/// (typically, initialize in SceneDelegate and inject where needed)
class RealmMessages: ObservableObject {

    // MARK:- Persons conformance
    @Published var all = [MessageModel]()

//    var allPublished: Published<[MessageModel]> { _all }
//    var allPublisher: Published<[MessageModel]>.Publisher { $all }

    init() {
        loadSavedData()
    }

    func add(message: MessageModel) {
        let realmMessage = buildRealmMessage(message: message)
        guard write(message: realmMessage) else { return }
            all.append(message)
            sort()
    }

    func update(message: MessageModel) {
        if let index = all.firstIndex(where: { $0.id  == message.id }) {
            let realmMessage = buildRealmMessage(message: message)
            guard write(message: realmMessage) else { return }
            all[index] = message
            sort()
        }
        else {
            print("message not found")
        }
    }

    func remove(messageRemove: MessageModel) {
        for (index, message) in all.enumerated() {
            if message.id == messageRemove.id {
                let realmMessage = buildRealmMessage(message: message)
                guard delete(message: realmMessage) else { continue }
                all.remove(at: index)
            }
        }
    }
    
    func removeAll(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func allMessageInGroup(groupId: Int64) -> [MessageModel] {
        return all.filter{$0.groupID == groupId}
    }
    
    func isExistMessage(msgId: String) -> Bool{
        let filter = all.filter{$0.id == msgId}
        return !filter.isEmpty
    }
    
    func getTimeStampPreLastMessage(groupId: Int64) -> Int64{
        let messageInGroup = all.filter{$0.groupID == groupId}
        var timeStamp : Int64 = 0
        if !messageInGroup.isEmpty {
            timeStamp = messageInGroup[messageInGroup.count - 1].createdAt
        }
        return timeStamp
    }

    // MARK: - Private functions
    private func write(message: RealmMessage) -> Bool {
        realmWrite { realm in
            realm.add(message, update: .modified)
        }
    }

    private func delete(message: RealmMessage) -> Bool {
        realmWrite { realm in
            if let message = realm.object(ofType: RealmMessage.self,
                                         forPrimaryKey: message.id) {
                realm.delete(message)
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

            let objects = realm.objects(RealmMessage.self)

            let messages: [MessageModel] = objects.map { object in
                self.buildMessage(realmMessage: object)
            }

            DispatchQueue.main.async {
                self.all = messages
                self.sort()
            }
        }
    }

    private func buildMessage(realmMessage: RealmMessage) -> MessageModel {
        
        let message = MessageModel(id: realmMessage.id,
                                   groupID: realmMessage.groupID,
                                   groupType: realmMessage.groupType,
                                   fromClientID: realmMessage.fromClientID,
                                   clientID: realmMessage.clientID,
                                   message: realmMessage.message,
                                   createdAt: realmMessage.createdAt,
                                   updatedAt: realmMessage.updatedAt)
        return message
    }

    private func buildRealmMessage(message: MessageModel) -> RealmMessage {
        let realmMessage = RealmMessage()
        realmMessage.id = message.id
        copyMessageAttributes(from: message, to: realmMessage)

        return realmMessage
    }

    private func copyMessageAttributes(from message: MessageModel, to realmMessage: RealmMessage) {
        realmMessage.groupID = message.groupID
        realmMessage.groupType = message.groupType
        realmMessage.fromClientID = message.fromClientID
        realmMessage.clientID = message.clientID
        realmMessage.message = message.message
        realmMessage.createdAt = message.createdAt
        realmMessage.updatedAt = message.updatedAt
    }
    
    private func sort() {
        all.sort(by: { $0.createdAt < $1.createdAt } )
    }

}
