//
//  MessageChatViewModel.swift
//  ClearKeep
//
//  Created by VietAnh on 10/30/20.
//

import Foundation
import Combine
import SwiftUI
import AVFoundation

class MessageChatViewModel: ObservableObject, Identifiable {
    // MARK: - Constants
    private let connectionDb = CKDatabaseManager.shared.database?.newConnection()
    
    // MARK: - Variables
    private(set) var ourEncryptionManager: CKAccountSignalEncryptionManager?
    private(set) var groupId: Int64 = 0
    private(set) var clientId: String = ""
    private(set) var username: String = ""
    private(set) var groupType: String = "peer"
    private(set) var isGroup: Bool = false
    
    private var isRequesting = false
    
    // MARK: - Published
    @Published var messages: [MessageModel] = []
    @Published var isForceProcessKey: Bool = true
    
    // MARK: - Init & Deinit
    init() {
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
    }
    
    deinit {
        Debug.DLog("Deinit \(self)")
    }
    
    func setup(clientId: String, username: String, groupId: Int64, groupType: String) {
        self.groupId = groupId
        self.clientId = clientId
        self.username = username
        self.groupType = groupType
        isGroup = false
        messages = RealmManager.shared.realmMessages.allMessageInGroup(groupId: groupId)
    }
    
    func setup(groupId: Int64, groupType: String) {
        self.groupId = groupId
        self.groupType = groupType
        isGroup = true
        messages = RealmManager.shared.realmMessages.allMessageInGroup(groupId: groupId)
    }
    
    // MARK: - Data managements
    func getGroupModel() -> GroupModel? {
        return RealmManager.shared.realmGroups.filterGroup(groupId: groupId)
    }
    
    func getMessageInRoom(completion: (() -> ())? = nil) {
        if isExistedGroup() {
            Backend.shared.getMessageInRoom(groupId,
                                            RealmManager.shared.realmGroups.getTimeSyncInGroup(groupID: groupId)) { (result, error) in
                if let result = result {
                    if !result.lstMessage.isEmpty {
                        DispatchQueue.main.async {
                            let listMsgSorted = result.lstMessage.sorted { (msg1, msg2) -> Bool in
                                return msg1.createdAt > msg2.createdAt
                            }
                            RealmManager.shared.realmGroups.updateTimeSyncMessageInGroup(groupID: self.groupId, lastMessageAt: listMsgSorted[0].createdAt)
                        }
                    }
                    result.lstMessage.forEach { (message) in
                        let filterMessage = RealmManager.shared.realmMessages.allMessageInGroup(groupId: message.groupID).filter{$0.id == message.id}
                        if filterMessage.isEmpty {
                            if let ourEncryptionMng = self.ourEncryptionManager {
                                do {
                                    let decryptedData = try ourEncryptionMng.decryptFromAddress(message.message,
                                                                                                name: self.clientId)
                                    let messageDecryption = String(data: decryptedData, encoding: .utf8)
                                    Debug.DLog("Message decryption: \(messageDecryption ?? "Empty error")")
                                    
                                    DispatchQueue.main.async {
                                        let post = MessageModel(id: message.id,
                                                                groupID: message.groupID,
                                                                groupType: message.groupType,
                                                                fromClientID: message.fromClientID,
                                                                fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: message.fromClientID, groupID: message.groupID),
                                                                clientID: message.clientID,
                                                                message: decryptedData,
                                                                createdAt: message.createdAt,
                                                                updatedAt: message.updatedAt)
                                        RealmManager.shared.realmMessages.add(message: post)
                                        self.messages.append(post)
                                        self.groupId = message.groupID
                                        RealmManager.shared.realmGroups.updateLastMessage(groupID: message.groupID, lastMessage: decryptedData, lastMessageAt: message.createdAt, idLastMessage: message.id)
                                    }
                                } catch {
                                    Debug.DLog("Decryption message error: \(error)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func isExistedGroup() -> Bool {
        if groupId == 0, let group = RealmManager.shared.realmGroups.getGroup(clientId: clientId) {
            groupId = group.groupID
        }
        
        return groupId != 0
    }
    
    func createGroup(username: String, clientId: String, completion: ((GroupModel) -> ())?) {
        guard let myAccount = CKSignalCoordinate.shared.myAccount else {
            return Debug.DLog("My Account is nil")
        }
        
        var req = Group_CreateGroupRequest()
        let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserID) ?? "") as String
        req.groupName = "\(username)-\(userNameLogin)"
        req.groupType = "peer"
        req.createdByClientID = myAccount.username
        req.lstClientID = [myAccount.username , clientId]
        
        Backend.shared.createRoom(req) { (result , error)  in
            if let result = result {
                let lstClientID = result.lstClient.map{ GroupMember(id: $0.id, username: $0.displayName)}
                
                DispatchQueue.main.async {
                    let group = GroupModel(groupID: result.groupID,
                                           groupName: result.groupName,
                                           groupToken: result.groupRtcToken,
                                           groupAvatar: result.groupAvatar,
                                           groupType: result.groupType,
                                           createdByClientID: result.createdByClientID,
                                           createdAt: result.createdAt,
                                           updatedByClientID: result.updatedByClientID,
                                           lstClientID: lstClientID,
                                           updatedAt: result.updatedAt,
                                           lastMessageAt: result.lastMessageAt,
                                           lastMessage: Data(),
                                           idLastMessage: result.lastMessage.id,
                                           timeSyncMessage: 0)
                    self.groupId = group.groupID
                    RealmManager.shared.realmGroups.add(group: group)
                    completion?(group)
                }
            }
        }
    }
    
    func isExistMessage(msgId: String) -> Bool {
        return RealmManager.shared.realmMessages.isExistMessage(msgId: msgId)
    }
    
    func getIdLastItem() -> String {
        var id = ""
        if messages.count > 0 {
            id = messages[messages.count - 1].id
        }
        return id
    }
    
    // MARK: - Send & received message
    func sendMessage(payload: Data, fromClientId: String, completion: ((MessageModel) -> ())?) {
        if isGroup {
            do {
                guard let encryptedData = try ourEncryptionManager?.encryptToGroup(payload,
                                                                                   groupId: groupId,
                                                                                   name: fromClientId) else { return }
                
                Backend.shared.send(encryptedData.data, fromClientId: fromClientId, groupId: groupId, groupType: groupType) { (result) in
                    if let result = result {
                        DispatchQueue.main.async {
                            let messageModel = MessageModel(id: result.id,
                                                            groupID: result.groupID,
                                                            groupType: result.groupType,
                                                            fromClientID: result.fromClientID,
                                                            fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: result.fromClientID, groupID: result.groupID),
                                                            clientID: result.clientID,
                                                            message: payload,
                                                            createdAt: result.createdAt,
                                                            updatedAt: result.updatedAt)
                            
                            RealmManager.shared.realmMessages.add(message: messageModel)
                            self.messages.append(messageModel)
                            RealmManager.shared.realmGroups.updateLastMessage(groupID: messageModel.groupID,
                                                                              lastMessage: messageModel.message,
                                                                              lastMessageAt: messageModel.createdAt,
                                                                              idLastMessage: messageModel.id)
                            completion?(messageModel)
                        }
                    }
                }
            } catch {
                Debug.DLog("Send message error: \(error)")
            }
        } else {
            guard let ourEncryptionManager = ourEncryptionManager,
                  ourEncryptionManager.sessionRecordExistsForUsername(clientId, deviceId: 111) else {
                requestBundleRecipient(byClientId: clientId) {
                    self.sendMessage(payload: payload, fromClientId: fromClientId, completion: completion)
                }
                return
            }
            
            func send() {
                do {
                    let encryptedData = try ourEncryptionManager.encryptToAddress(payload,
                                                                                  name: clientId)
                    
                    Backend.shared.send(encryptedData.data, fromClientId: fromClientId, toClientId: self.clientId , groupId: self.groupId , groupType: self.groupType) { (result) in
                        if let result = result {
                            DispatchQueue.main.async {
                                let messageModel = MessageModel(id: result.id,
                                                                groupID: result.groupID,
                                                                groupType: result.groupType,
                                                                fromClientID: result.fromClientID,
                                                                fromDisplayName:  RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: result.fromClientID, groupID: result.groupID),
                                                                clientID: result.clientID,
                                                                message: payload,
                                                                createdAt: result.createdAt,
                                                                updatedAt: result.updatedAt)
                                RealmManager.shared.realmMessages.add(message: messageModel)
                                
                                self.messages.append(messageModel)
                                RealmManager.shared.realmGroups.updateLastMessage(groupID: messageModel.groupID,
                                                                                  lastMessage: messageModel.message,
                                                                                  lastMessageAt: messageModel.createdAt,
                                                                                  idLastMessage: messageModel.id)
                                completion?(messageModel)
                            }
                        }
                    }
                    
                } catch {
                    Debug.DLog("Send message error: \(error)")
                }
            }
            requestBundleRecipient(byClientId: clientId) {
                send()
            }
        }
    }
    
    func decryptionMessage(publication: Message_MessageObjectResponse, completion: ((MessageModel) -> ())?) {
        guard let ourEncryptionMng = ourEncryptionManager else { return }
        
        if isGroup {
            guard let senderAccount = self.getSenderAccount(fromClientID: publication.fromClientID) else {
                return
            }
            if ourEncryptionMng.senderKeyExistsForUsername(publication.fromClientID, deviceId: senderAccount.deviceId, groupId: groupId) {
                let messageDecryption = decryptedMessage(messageData: publication.message, fromClientID: publication.fromClientID)
                
                let messageModel = MessageModel(id: publication.id,
                                                groupID: publication.groupID,
                                                groupType: publication.groupType,
                                                fromClientID: publication.fromClientID,
                                                fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
                                                clientID: publication.clientID,
                                                message: messageDecryption,
                                                createdAt: publication.createdAt,
                                                updatedAt: publication.updatedAt)
                RealmManager.shared.realmMessages.add(message: messageModel)
                self.messages.append(messageModel)
                RealmManager.shared.realmGroups.updateLastMessage(groupID: messageModel.groupID, lastMessage: messageModel.message, lastMessageAt: messageModel.createdAt, idLastMessage: messageModel.id)
                completion?(messageModel)
            } else {
                requestKeyInGroup(byGroupId: groupId, publication: publication, completion: completion)
                return
            }
        } else {
            let messageDecryption = decryptedMessage(messageData: publication.message, fromClientID: publication.fromClientID)
            
            let messageModel = MessageModel(id: publication.id,
                                            groupID: publication.groupID,
                                            groupType: publication.groupType,
                                            fromClientID: publication.fromClientID,
                                            fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
                                            clientID: publication.clientID,
                                            message: messageDecryption,
                                            createdAt: publication.createdAt,
                                            updatedAt: publication.updatedAt)
            RealmManager.shared.realmMessages.add(message: messageModel)
            self.messages.append(messageModel)
            RealmManager.shared.realmGroups.updateLastMessage(groupID: messageModel.groupID, lastMessage: messageModel.message, lastMessageAt: messageModel.createdAt, idLastMessage: messageModel.id)
            completion?(messageModel)
        }
    }
    
    // MARK: - Private functions
    private func getSenderAccount(fromClientID: String) -> CKAccount? {
        if let connectionDb = self.connectionDb {
            var account: CKAccount?
            connectionDb.read { (transaction) in
                account = CKAccount.allAccounts(withUsername: fromClientID, transaction: transaction).first
            }
            return account
        }
        return nil
    }
    
    
    func callPeerToPeer(groupId: Int64, clientId: String, callType type: Constants.CallType = .audio, completion: (() -> ())? = nil){
        if isRequesting { return }
        isRequesting = true
        requestVideoCall(isCallGroup: false, clientId: clientId, groupId: groupId, callType: type, completion: completion)
    }
    
    func callGroup(groupId: Int64, callType type: Constants.CallType = .audio, completion: (() -> ())? = nil){
        if isRequesting { return }
        isRequesting = true
        requestVideoCall(isCallGroup: true, groupId: groupId, callType: type, completion: completion)
    }
    
    private func requestVideoCall(isCallGroup: Bool ,clientId: String = "", groupId: Int64, callType type: Constants.CallType = .audio, completion: (() -> ())?) {
        Backend.shared.videoCall(clientId, groupId, callType: type) { (response, error) in
            self.isRequesting = false
            completion?()
            if let response = response {
                if response.hasStunServer {
                    DispatchQueue.main.async {
                        UserDefaults.standard.setValue(response.turnServer.user, forKey: Constants.keySaveTurnServerUser)
                        UserDefaults.standard.setValue(response.turnServer.pwd, forKey: Constants.keySaveTurnServerPWD)
                        UserDefaults.standard.synchronize()
                        
                        AVCaptureDevice.authorizeVideo(completion: { (status) in
                            AVCaptureDevice.authorizeAudio(completion: { (status) in
                                if status == .alreadyAuthorized || status == .justAuthorized {
                                    CallManager.shared.startCall(clientId: clientId,
                                                                 clientName: self.username,
                                                                 avatar: "",
                                                                 groupId: groupId,
                                                                 groupToken: response.groupRtcToken,
                                                                 callType: type,
                                                                 isCallGroup: isCallGroup)
                                }
                            })
                        })
                    }
                }
            }
        }
    }
    
    func requestBundleRecipient(byClientId clientId: String,_ completion: @escaping () -> Void) {
        
        Backend.shared.authenticator
            .requestKey(byClientId: clientId) { [weak self](result, error, response) in
                
                guard let recipientResponse = response else {
                    Debug.DLog("Request prekey \(clientId) fail")
                    return
                }
                //                // check exist session recipient in database
                //                //                if let ourAccountEncryptMng = self?.ourEncryptionManager {
                //                self?.recipientDeviceId = UInt32(recipientResponse.deviceID)
                //                //                    if !ourAccountEncryptMng.sessionRecordExistsForUsername(clientId, deviceId: 555) {
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
                                
                                let device = CKDevice(deviceId: NSNumber(value:111),
                                                      trustLevel: .trustedTofu,
                                                      parentKey: buddy.uniqueId,
                                                      parentCollection: CKBuddy.collection,
                                                      publicIdentityKeyData: nil,
                                                      lastSeenDate:nil)
                                device.save(with:transaction)
                            } else {
                                myBuddy?.save(with: transaction)
                                let device = CKDevice(deviceId: NSNumber(value:111),
                                                      trustLevel: .trustedTofu,
                                                      parentKey: myBuddy!.uniqueId,
                                                      parentCollection: CKBuddy.collection,
                                                      publicIdentityKeyData: nil,
                                                      lastSeenDate:nil)
                                device.save(with:transaction)
                            }
                        }
                    })
                }
                //                    // Case: 1 register user with server with publicKey, privateKey (preKey, signedPreKey)
                self?.processKeyStoreHasPrivateKey(recipientResponse: recipientResponse)
                //
                //                    // Case: 2 register user with server with only publicKey (preKey, signedPreKey)
                //                    //                                            self?.processKeyStoreOnlyPublicKey(recipientResponse: recipientResponse)
                //                    //                    }
                //                    print("processPreKeyBundle recipient finished")
                completion()
                //                }
                //                    completion()
                //                }
            }
        //        }
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
                                                                deviceId: UInt32(111),
                                                                preKeyId: UInt32(recipientResponse.preKeyID),
                                                                preKeyPublic: preKeyKeyPair.publicKey,
                                                                signedPreKeyId: UInt32(recipientResponse.signedPreKeyID),
                                                                signedPreKeyPublic: signedPrekeyKeyPair.publicKey,
                                                                signature: recipientResponse.signedPreKeySignature,
                                                                identityKey: recipientResponse.identityKeyPublic)
                
                let remoteAddress = SignalAddress(name: recipientResponse.clientID,
                                                  deviceId: 111)
                let remoteSessionBuilder = SignalSessionBuilder(address: remoteAddress,
                                                                context: ourEncryptionMng.signalContext)
                try remoteSessionBuilder.processPreKeyBundle(signalPreKeyBundle)
            } catch {
                Debug.DLog("processKeyStoreHasPrivateKey exception: \(error)")
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
                
                let bundle = CKBundle(deviceId: UInt32(111),
                                      registrationId: UInt32(recipientResponse.registrationID),
                                      identityKey: recipientResponse.identityKeyPublic,
                                      signedPreKey: ckSignedPreKey,
                                      preKeys: [ckPreKey])
                try ourEncryptionMng.consumeIncomingBundle(recipientResponse.clientID, bundle: bundle)
            } catch {
                Debug.DLog("processKeyStoreOnlyPublicKey exception: \(error)")
            }
        }
    }
    
    private func decryptedMessage(messageData: Data, fromClientID: String) -> Data {
        let messageError = "unable to decrypt this message".data(using: .utf8) ?? Data()
        guard let ourEncryptionMng = self.ourEncryptionManager else { return messageError }
        do {
            if isGroup {
                return try ourEncryptionMng.decryptFromGroup(messageData,
                                                             groupId: groupId,
                                                             name: fromClientID)
            } else {
                return try ourEncryptionMng.decryptFromAddress(messageData,
                                                               name: fromClientID)
            }
        } catch {
            return messageError
        }
    }
    
    func requestKeyInGroup(byGroupId groupId: Int64, publication: Message_MessageObjectResponse, completion: ((MessageModel) -> ())?) {
        if self.isForceProcessKey {
            Backend.shared.authenticator.requestKeyGroup(byClientId: publication.fromClientID,
                                                         groupId: groupId) {(result, error, response) in
                guard let groupResponse = response else {
                    Debug.DLog("Request prekey \(groupId) fail")
                    return
                }
                self.processSenderKey(byGroupId: groupResponse.groupID,
                                      responseSenderKey: groupResponse.clientKey)
                // decrypt message again
                self.decryptionMessage(publication: publication, completion: completion)
                self.isForceProcessKey = false
            }
        }
    }
    
    func processSenderKey(byGroupId groupId: Int64,
                          responseSenderKey: Signal_GroupClientKeyObject) {
        let deviceID = 222
        if let ourAccountEncryptMng = self.ourEncryptionManager,
           let connectionDb = self.connectionDb {
            // save account infor
            connectionDb.readWrite { (transaction) in
                var account = CKAccount.allAccounts(withUsername: responseSenderKey.clientID, transaction: transaction).first
                if account == nil {
                    account = CKAccount(username: responseSenderKey.clientID, deviceId: Int32(deviceID), accountType: .none)
                    account?.save(with: transaction)
                }
            }
            do {
                let addresss = SignalAddress(name: responseSenderKey.clientID,
                                             deviceId: Int32(deviceID))
                try ourAccountEncryptMng.consumeIncoming(toGroup: groupId,
                                                         address: addresss,
                                                         skdmDtata: responseSenderKey.clientKeyDistribution)
            } catch {
                Debug.DLog("processSenderKey error: \(error)")
            }
        }
    }
    
    func registerWithGroup(_ groupId: Int64) {
        if let group = RealmManager.shared.realmGroups.filterGroup(groupId: groupId) {
            if !group.isRegister {
                if let myAccount = CKSignalCoordinate.shared.myAccount , let ourAccountEncryptMng = self.ourEncryptionManager {
                    let userName = myAccount.username
                    let deviceID = Int32(111)
                    let address = SignalAddress(name: userName, deviceId: deviceID)
                    let groupSessionBuilder = SignalGroupSessionBuilder(context: ourAccountEncryptMng.signalContext)
                    let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
                    
                    do {
                        let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
                        Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                                   clientId: userName,
                                                                   deviceId: deviceID,
                                                                   senderKeyData: signalSKDM.serializedData()) { (result, error) in
                            Debug.DLog("Register group with result: \(result)")
                            if result {
                                RealmManager.shared.realmGroups.registerGroup(groupId: groupId)
                            }
                        }
                        
                    } catch {
                        Debug.DLog("Register group error: \(error)")
                    }
                }
            }
        }
    }
    
}
