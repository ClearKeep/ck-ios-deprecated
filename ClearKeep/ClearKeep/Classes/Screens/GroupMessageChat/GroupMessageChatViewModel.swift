//
//  GroupMessageChatViewModel.swift
//  ClearKeep
//
//  Created by VietAnh on 11/5/20.
//

import Foundation

class GroupMessageChatViewModel: ObservableObject, Identifiable {
    let groupId: String
    var ourEncryptionManager: CKAccountSignalEncryptionManager?
    var recipientDeviceId: UInt32 = 0
    @Published var messages: [MessageModel] = []
    
    init(groupId: String) {
        self.groupId = groupId
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
        requestAllKeyInGroup(byGroupId: groupId)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMessage),
                                               name: NSNotification.Name("DidReceiveMessageGroup"),
                                               object: nil)
    }
    
    @objc func didReceiveMessage(notification: NSNotification) {
        print("didReceiveMessage \(String(describing: notification.userInfo))")
        if let userInfo = notification.userInfo,
            let publication = userInfo["publication"] as? SignalcGroup_GroupPublication,
           publication.groupID == self.groupId { // need check groupId
            decryptionMessage(publication: publication)
        }
    }
    
    func decryptionMessage(publication: SignalcGroup_GroupPublication) {
        if let ourEncryptionMng = self.ourEncryptionManager {
            do {
                let decryptedData = try ourEncryptionMng.decryptFromGroup(publication.message,
                                                                          groupId: self.groupId,
                                                                          name: publication.senderID,
                                                                          deviceId: UInt32(1))
                let messageDecryption = String(data: decryptedData, encoding: .utf8)
                print("Message decryption: \(messageDecryption ?? "Empty error")")
                let post = MessageModel(from: publication.senderID, data: decryptedData)
                messages.append(post)
            } catch {
                print("Decryption message error: \(error)")
                requestKeyInGroup(byGroupId: self.groupId, publication: publication)
            }
        }
    }
    
    func requestKeyInGroup(byGroupId groupId: String, publication: SignalcGroup_GroupPublication) {
        Backend.shared.authenticator.requestKeyGroup(bySenderId: publication.senderID,
                                                     groupId: groupId) { [weak self](result, error, response) in
            guard let groupResponse = response else {
                print("Request prekey \(groupId) fail")
                return
            }
            if let ourEncryptionMng = self?.ourEncryptionManager {
                if !ourEncryptionMng.senderKeyExistsForUsername(groupResponse.senderKey.senderID,
                                                                    deviceId: 1,
                                                                    groupId: groupId) {
                    self?.processSenderKey(byGroupId: groupResponse.groupID,
                                           responseSenderKey: groupResponse.senderKey)
                    
                    // decrypt message again
                    self?.decryptionMessage(publication: publication)
                }
            }
        }
    }
    
    func requestAllKeyInGroup(byGroupId groupId: String) {
        Backend.shared.authenticator.requestAllKeyInGroup(byGroup: groupId) { [weak self](result, error, response) in
            guard let allKeyGroupResponse = response else {
                print("Request prekey \(groupId) fail")
                return
            }
            
            if let ourAccountEncryptMng = self?.ourEncryptionManager {
                for groupSenderKeyObj in allKeyGroupResponse.allSenderKey {
                    // check processed senderKey
                    if !ourAccountEncryptMng.senderKeyExistsForUsername(groupSenderKeyObj.senderID,
                                                                        deviceId: groupSenderKeyObj.deviceID,
                                                                        groupId: groupId) {
                        self?.processSenderKey(byGroupId: allKeyGroupResponse.groupID,
                                               responseSenderKey: groupSenderKeyObj)
                    }
                }
                print("processPreKeyBundle group finished: \(allKeyGroupResponse.allSenderKey.count) members")
            }
        }
    }
    
    private func processSenderKey(byGroupId groupId: String,
                                  responseSenderKey: SignalcGroup_GroupSenderKeyObject) {
        if let ourAccountEncryptMng = self.ourEncryptionManager {
            do {
                let addresss = SignalAddress(name: responseSenderKey.senderID,
                                             deviceId: responseSenderKey.deviceID)
                try ourAccountEncryptMng.consumeIncoming(toGroup: groupId,
                                                         address: addresss,
                                                         skdmDtata: responseSenderKey.senderKeyDistribution)
            } catch {
                print("processSenderKey error: \(error)")
            }
        }
    }
        
    func send(messageStr: String) {
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            do {
                let post = MessageModel(from: myAccount.username, data: payload)
                messages.append(post)
                
                let encryptedData = try ourEncryptionManager?.encryptToGroup(payload,
                                                                             groupId: self.groupId,
                                                                             name: myAccount.username,
                                                                             deviceId: UInt32(myAccount.deviceId))
                Backend.shared.send(toGroup: self.groupId,
                                    message: encryptedData!.data,
                                    senderId: myAccount.username) { (result, error) in
                    print("Send message to group \(self.groupId) result: \(result)")
                }
            } catch {
                print("Send message error: \(error)")
            }
        }
    }
}
