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
    let connectionDb = CKDatabaseManager.shared.database?.newConnection()
    var messsages = RealmMessages()
    
    init(groupId: String) {
        self.groupId = groupId
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
        requestAllKeyInGroup(byGroupId: groupId)
        registerWithGroup(groupId)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMessage),
                                               name: NSNotification.Name("DidReceiveSignalMessage"),
                                               object: nil)
    }
    
    @objc func didReceiveMessage(notification: NSNotification) {
        print("didReceiveMessage \(String(describing: notification.userInfo))")
        if let userInfo = notification.userInfo,
           let publication = userInfo["publication"] as? Message_MessageObjectResponse,
           publication.groupID == self.groupId { // need check groupId
            decryptionMessage(publication: publication)
        }
    }
    
    func decryptionMessage(publication: Message_MessageObjectResponse) {
        if let ourEncryptionMng = self.ourEncryptionManager,
           let connectionDb = self.connectionDb {
            do {
                var account: CKAccount?
                connectionDb.read { (transaction) in
                    account = CKAccount.allAccounts(withUsername: publication.fromClientID, transaction: transaction).first
                }
                if let senderAccount = account {
                    if ourEncryptionMng.senderKeyExistsForUsername(publication.fromClientID, deviceId: senderAccount.deviceId, groupId: groupId) {
                        let decryptedData = try ourEncryptionMng.decryptFromGroup(publication.message,
                                                                                  groupId: self.groupId,
                                                                                  name: publication.fromClientID,
                                                                                  deviceId: UInt32(senderAccount.deviceId))
                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
                        print("Message decryption: \(messageDecryption ?? "Empty error")")
                        
                        DispatchQueue.main.async {
                            let post = MessageModel(id: publication.id,
                                                    groupID: publication.groupID,
                                                    groupType: publication.groupType,
                                                    fromClientID: publication.fromClientID,
                                                    clientID: publication.clientID,
                                                    message: decryptedData,
                                                    createdAt: publication.createdAt,
                                                    updatedAt: publication.updatedAt)
                            self.messsages.add(message: post)
                        }
                        
                        return
                    }
                }
            } catch {
                print("Decryption message error: \(error)")
                requestKeyInGroup(byGroupId: self.groupId, publication: publication)
            }
            requestKeyInGroup(byGroupId: self.groupId, publication: publication)
        }
    }
    
    func requestKeyInGroup(byGroupId groupId: String, publication: Message_MessageObjectResponse) {
        Backend.shared.authenticator.requestKeyGroup(byClientId: publication.fromClientID,
                                                     groupId: groupId) { [weak self](result, error, response) in
            guard let groupResponse = response else {
                print("Request prekey \(groupId) fail")
                return
            }
            if let ourEncryptionMng = self?.ourEncryptionManager {
                if !ourEncryptionMng.senderKeyExistsForUsername(groupResponse.clientKey.clientID,
                                                                deviceId: groupResponse.clientKey.deviceID,
                                                                groupId: groupId) {
                    self?.processSenderKey(byGroupId: groupResponse.groupID,
                                           responseSenderKey: groupResponse.clientKey)
                    
                    // decrypt message again
                    self?.decryptionMessage(publication: publication)
                }
            }
        }
    }
    
    private func registerWithGroup(_ groupId: String) {
        if let myAccount = CKSignalCoordinate.shared.myAccount , let ourAccountEncryptMng = self.ourEncryptionManager {
            let userName = myAccount.username
            let deviceID = Int32(myAccount.deviceId)
            
            let address = SignalAddress(name: userName, deviceId: deviceID)
            let groupSessionBuilder = SignalGroupSessionBuilder(context: ourAccountEncryptMng.signalContext)
            let senderKeyName = SignalSenderKeyName(groupId: groupId, address: address)
            do {
                let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
                Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                           clientId: userName,
                                                           deviceId: deviceID,
                                                           senderKeyData: signalSKDM.serializedData()) { (result, error) in
                    print("Register group with result: \(result)")
                    if result {
                        Backend.shared.signalSubscrible(clientId: userName)
                    }
                }
                
            } catch {
                print("Register group error: \(error)")
                
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
                for groupSenderKeyObj in allKeyGroupResponse.lstClientKey {
                    // check processed senderKey
                    if !ourAccountEncryptMng.senderKeyExistsForUsername(groupSenderKeyObj.clientID,
                                                                        deviceId: groupSenderKeyObj.deviceID,
                                                                        groupId: groupId) {
                        self?.processSenderKey(byGroupId: allKeyGroupResponse.groupID,
                                               responseSenderKey: groupSenderKeyObj)
                    }
                }
                print("processPreKeyBundle group finished: \(allKeyGroupResponse.lstClientKey.count) members")
            }
        }
    }
    
    private func processSenderKey(byGroupId groupId: String,
                                  responseSenderKey: Signal_GroupClientKeyObject) {
        if let ourAccountEncryptMng = self.ourEncryptionManager,
           let connectionDb = self.connectionDb {
            // save account infor
            connectionDb.readWrite { (transaction) in
                var account = CKAccount.allAccounts(withUsername: responseSenderKey.clientID, transaction: transaction).first
                if account == nil {
                    account = CKAccount(username: responseSenderKey.clientID, deviceId: responseSenderKey.deviceID, accountType: .none)
                    account?.save(with: transaction)
                }
            }
            do {
                let addresss = SignalAddress(name: responseSenderKey.clientID,
                                             deviceId: responseSenderKey.deviceID)
                try ourAccountEncryptMng.consumeIncoming(toGroup: groupId,
                                                         address: addresss,
                                                         skdmDtata: responseSenderKey.clientKeyDistribution)
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
                guard let encryptedData = try ourEncryptionManager?.encryptToGroup(payload,
                                                                                   groupId: self.groupId,
                                                                                   name: myAccount.username,
                                                                                   deviceId: UInt32(myAccount.deviceId)) else { return }
                Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, groupId: self.groupId, groupType: "group") { (result) in
                    if let result = result {
                        DispatchQueue.main.async {
                            let post = MessageModel(id: result.id,
                                                    groupID: result.groupID,
                                                    groupType: result.groupType,
                                                    fromClientID: result.fromClientID,
                                                    clientID: result.clientID,
                                                    message: payload,
                                                    createdAt: result.createdAt,
                                                    updatedAt: result.updatedAt)
                            self.messsages.add(message: post)
                        }
                        
                    }
                    print("Send message to group \(self.groupId) result")
                }
            } catch {
                print("Send message error: \(error)")
            }
        }
    }
}
