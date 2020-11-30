//
//  MessageChatViewModel.swift
//  ClearKeep
//
//  Created by VietAnh on 10/30/20.
//

import Foundation
import Combine

class MessageChatViewModel: ObservableObject, Identifiable {
    let clientId: String
    var groupId: String = ""
    let chatWithUser: String
    var ourEncryptionManager: CKAccountSignalEncryptionManager?
    var recipientDeviceId: UInt32 = 0
    var isExistGroup = false
    @Published var messages: [MessageModel] = []
    
    init(clientId: String ,chatWithUser: String) {
        self.clientId = clientId
        self.chatWithUser = chatWithUser
        requestBundleRecipient(byClientId: clientId)
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMessage),
                                               name: NSNotification.Name("DidReceiveSignalMessage"),
                                               object: nil)
    }
    
    @objc func didReceiveMessage(notification: NSNotification) {
        print("didReceiveMessage \(String(describing: notification.userInfo))")
        if let userInfo = notification.userInfo,
           let clientId = userInfo["clientId"] as? String,
            let publication = userInfo["publication"] as? Message_MessageObjectResponse,
//            publication.groupID.isEmpty,
           clientId == self.clientId {
            if let ourEncryptionMng = self.ourEncryptionManager {
                do {
                    let decryptedData = try ourEncryptionMng.decryptFromAddress(publication.message,
                                                                                name: clientId,
                                                                                deviceId: recipientDeviceId)
                    let messageDecryption = String(data: decryptedData, encoding: .utf8)
                    print("Message decryption: \(messageDecryption ?? "Empty error")")
                    DispatchQueue.main.async {
                        let post = MessageModel(from: clientId, data: decryptedData)
                        self.messages.append(post)
                    }
                } catch {
                    print("Decryption message error: \(error)")
                }
            }
        }
    }
    
    func requestBundleRecipient(byClientId clientId: String) {
        Backend.shared.authenticator
            .requestKey(byClientId: clientId) { [weak self](result, error, response) in
                
                guard let recipientResponse = response else {
                    print("Request prekey \(clientId) fail")
                    return
                }
                // check exist session recipient in database
                if let ourAccountEncryptMng = self?.ourEncryptionManager {
                    self?.recipientDeviceId = UInt32(recipientResponse.deviceID)
                    if !ourAccountEncryptMng.sessionRecordExistsForUsername(clientId, deviceId: recipientResponse.deviceID) {
                        if let connectionDb = CKDatabaseManager.shared.database?.newConnection(),
                           let myAccount = CKSignalCoordinate.shared.myAccount {
                            // save devcice by recipient account
                            connectionDb.readWrite ({ (transaction) in
                                if let _ = myAccount.refetch(with: transaction) {
                                    let myBuddy = CKBuddy.fetchBuddy(username: recipientResponse.clientID,
                                                                     accountUniqueId: myAccount.uniqueId,
                                                                     transaction: transaction)
                                    if myBuddy == nil {
                                        let buddy = CKBuddy()!
                                        buddy.accountUniqueId = myAccount.uniqueId
                                        buddy.username = recipientResponse.clientID
                                        buddy.save(with:transaction)
                                        
                                        let device = CKDevice(deviceId: NSNumber(value:recipientResponse.deviceID),
                                                              trustLevel: .trustedTofu,
                                                              parentKey: buddy.uniqueId,
                                                              parentCollection: CKBuddy.collection,
                                                              publicIdentityKeyData: nil,
                                                              lastSeenDate:nil)
                                        device.save(with:transaction)
                                    }
                                }
                            })
                        }
                        // Case: 1 register user with server with publicKey, privateKey (preKey, signedPreKey)
                        self?.processKeyStoreHasPrivateKey(recipientResponse: recipientResponse)
                        
                        // Case: 2 register user with server with only publicKey (preKey, signedPreKey)
                        //                    self?.processKeyStoreOnlyPublicKey(recipientResponse: recipientResponse)
                    }
                    print("processPreKeyBundle recipient finished")
                }
            }
    }
    
    private func processKeyStoreHasPrivateKey(recipientResponse: Signal_PeerGetClientKeyResponse) {
        if let ourEncryptionMng = self.ourEncryptionManager {
            do {
                let remotePrekey = try SignalPreKey.init(serializedData: recipientResponse.preKey)
                let remoteSignedPrekey = try SignalPreKey.init(serializedData: recipientResponse.signedPreKey)
                
                guard let preKeyKeyPair = remotePrekey.keyPair,
                      let signedPrekeyKeyPair = remoteSignedPrekey.keyPair else {
                    return
                }
                
                let signalPreKeyBundle = try SignalPreKeyBundle(registrationId: UInt32(recipientResponse.registrationID),
                                                                deviceId: UInt32(recipientResponse.deviceID),
                                                                preKeyId: UInt32(recipientResponse.preKeyID),
                                                                preKeyPublic: preKeyKeyPair.publicKey,
                                                                signedPreKeyId: UInt32(recipientResponse.signedPreKeyID),
                                                                signedPreKeyPublic: signedPrekeyKeyPair.publicKey,
                                                                signature: recipientResponse.signedPreKeySignature,
                                                                identityKey: recipientResponse.identityKeyPublic)
                
                let remoteAddress = SignalAddress(name: recipientResponse.clientID,
                                                  deviceId: recipientResponse.deviceID)
                let remoteSessionBuilder = SignalSessionBuilder(address: remoteAddress,
                                                                context: ourEncryptionMng.signalContext)
                try remoteSessionBuilder.processPreKeyBundle(signalPreKeyBundle)
            } catch {
                print("processKeyStoreHasPrivateKey exception: \(error)")
            }
        }
    }
    
    private func processKeyStoreOnlyPublicKey(recipientResponse: Signal_PeerGetClientKeyResponse) {
        if let ourEncryptionMng = self.ourEncryptionManager {
            do {
                let ckSignedPreKey = CKSignedPreKey(withPreKeyId: UInt32(recipientResponse.signedPreKeyID),
                                                    publicKey: recipientResponse.signedPreKey,
                                                    signature: recipientResponse.signedPreKeySignature)
                let ckPreKey = CKPreKey(withPreKeyId: UInt32(recipientResponse.preKeyID),
                                        publicKey: recipientResponse.preKey)
                
                let bundle = CKBundle(deviceId: UInt32(recipientResponse.deviceID),
                                      registrationId: UInt32(recipientResponse.registrationID),
                                      identityKey: recipientResponse.identityKeyPublic,
                                      signedPreKey: ckSignedPreKey,
                                      preKeys: [ckPreKey])
                try ourEncryptionMng.consumeIncomingBundle(recipientResponse.clientID, bundle: bundle)
            } catch {
                print("processKeyStoreOnlyPublicKey exception: \(error)")
            }
        }
    }
    
    func getMessageInRoom(){
//        var listGroup = CKExtensions.getAllGroup
//        listGroup = listGroup.filter {$0.groupType == "peer"}
//        listGroup.forEach { (group) in
//            if group.lstClientID.contains(self.clientId) {
//                self.groupId = group.groupID
//                self.isExistGroup = true
//            }
//        }

        if self.isExistGroup {
            Backend.shared.getMessageInRoom(self.groupId) { (result, error) in
                if let result = result {
                    result.lstMessage.forEach { (message) in
                        DispatchQueue.main.async {
//                            if let ourEncryptionMng = self.ourEncryptionManager {
//                                do {
//                                    let decryptedData = try ourEncryptionMng.decryptFromAddress(message.message,
//                                                                                                name: self.clientId,
//                                                                                                deviceId: self.recipientDeviceId)
//                                    let messageDecryption = String(data: decryptedData, encoding: .utf8)
//                                    print("Message decryption: \(messageDecryption ?? "Empty error")")
//                                    DispatchQueue.main.async {
//                                        let post = MessageModel(from: self.clientId, data: decryptedData)
//                                        self.messages.append(post)
//                                    }
//                                } catch {
//                                    print("Decryption message error: \(error)")
//                                }
//                            }
                        }
                    }
                }
            }
        }
    }
    
    func send(messageStr: String) {
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            do {
                requestBundleRecipient(byClientId: clientId)
//                if messages.isEmpty {
//                    Backend.shared.createRoom(req) { (result) in
//                        print(result.groupID)
//                    }
//                }
                var req = Group_CreateGroupRequest()
                let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserNameLogin) ?? "") as String
                req.groupName = "\(self.chatWithUser)-\(userNameLogin)"
                req.groupType = "peer"
                req.createdByClientID = myAccount.username
                req.lstClientID = [myAccount.username , self.clientId]
                
                guard let encryptedData = try ourEncryptionManager?.encryptToAddress(payload,
                                                                               name: clientId,
                                                                               deviceId: recipientDeviceId) else { return }
                if !isExistGroup {
                    Backend.shared.createRoom(req) { (result) in
                        self.groupId = result.groupID
                        self.isExistGroup = true
                        Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, toClientId: self.clientId , groupId: self.groupId , groupType: "peer") { (result, error) in
                            if result {
                                DispatchQueue.main.async {
                                    let post = MessageModel(from: myAccount.username, data: payload)
                                    self.messages.append(post)
                                }
                            }
                        }
                    }
                } else {
                    Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, toClientId: self.clientId , groupId: self.groupId , groupType: "peer") { (result, error) in
                        if result {
                            DispatchQueue.main.async {
                                let post = MessageModel(from: myAccount.username, data: payload)
                                self.messages.append(post)
                            }
                        }
                    }
                }



            } catch {
                print("Send message error: \(error)")
            }
        }
    }
}
