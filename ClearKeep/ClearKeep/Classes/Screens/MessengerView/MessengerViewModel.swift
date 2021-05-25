//
//  MessengerViewModel.swift
//  ClearKeep
//
//  Created by VietAnh on 11/10/20.
//

import Foundation
import AVFoundation

class MessengerViewModel: ObservableObject, Identifiable {
    
    // MARK: - Constants
    private let connectionDb = CKDatabaseManager.shared.database?.newConnection()
    
    // MARK: - Variables
    private(set) var ourEncryptionManager: CKAccountSignalEncryptionManager?
    private(set) var groupId: Int64 = 0
    private(set) var clientId: String = ""
    private(set) var username: String = ""
    private(set) var groupType: String = "peer"
    private(set) var isGroup: Bool = false
    private(set) var recipientDeviceId: UInt32 = 0
    private var isRequesting = false
    
    // MARK: - Published
    @Published var messages: [MessageModel] = []
    
    // MARK: - Init & Deinit
    init() {
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
    }
    
    deinit {
        Debug.DLog("Deinit \(self)")
    }
    
    func setup(clientId: String, groupId: Int64, username: String, groupType: String) {
        self.clientId = clientId
        self.username = username
        self.groupId = groupId
        self.groupType = groupType
        isGroup = false
        messages = RealmManager.shared.realmMessages.allMessageInGroup(groupId: groupId)
    }
    
    func setup(groupId: Int64, username: String, groupType: String) {
        self.groupId = groupId
        self.groupType = groupType
        self.username = username
        isGroup = true
        messages = RealmManager.shared.realmMessages.allMessageInGroup(groupId: groupId)
    }
    
    // MARK: - Data managements
    func getGroupModel() -> GroupModel? {
        return RealmManager.shared.realmGroups.filterGroup(groupId: groupId)
    }
    
    func getIdLastItem() -> String {
        var id = ""
        if messages.count > 0 {
            id = messages[messages.count - 1].id
        }
        return id
    }
    
    func getMessageInRoom(completion: (() -> ())? = nil) {
        if isGroup {
            getMessageGroup(completion: completion)
        } else {
            getMessagePeerToPeer(completion: completion)
        }
    }
    
    private func getMessagePeerToPeer(completion: (() -> ())? = nil) {
        if self.groupId != 0 {
            Backend.shared.getMessageInRoom(self.groupId,
                                            RealmManager.shared.realmGroups.getTimeSyncInGroup(groupID: self.groupId)) { (result, error) in
                if let result = result {
                    if !result.lstMessage.isEmpty {
                        DispatchQueue.main.async {
                            RealmManager.shared.realmGroups.updateTimeSyncMessageInGroup(groupID: self.groupId, lastMessageAt: result.lstMessage.last?.createdAt ?? 0)
                        }
                    }
                    result.lstMessage.forEach { (message) in
                        let filterMessage = RealmManager.shared.realmMessages.allMessageInGroup(groupId: message.groupID).filter{$0.id == message.id}
                        if filterMessage.isEmpty {
                            if let ourEncryptionMng = self.ourEncryptionManager {
                                do {
                                    let decryptedData = try ourEncryptionMng.decryptFromAddress(message.message,
                                                                                                name: self.clientId,
                                                                                                deviceId: UInt32(555))
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
                                        completion?()
                                    }
                                } catch {
                                    Debug.DLog("Decryption message error: \(error)")
                                }
                            }
                        }
                    }
                    completion?()
                }
            }
        }
    }
    
    private func getMessageGroup(completion: (() -> ())? = nil) {
        if groupId != 0 {
            Backend.shared.getMessageInRoom(groupId , RealmManager.shared.realmGroups.getTimeSyncInGroup(groupID: groupId)) { (result, error) in
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
                            if let ourEncryptionMng = self.ourEncryptionManager,
                               let connectionDb = self.connectionDb {
                                do {
                                    var account: CKAccount?
                                    connectionDb.read { (transaction) in
                                        account = CKAccount.allAccounts(withUsername: message.fromClientID, transaction: transaction).first
                                    }
                                    if let senderAccount = account {
                                        if ourEncryptionMng.senderKeyExistsForUsername(message.fromClientID, deviceId: senderAccount.deviceId, groupId: message.groupID) {
                                            let decryptedData = try ourEncryptionMng.decryptFromGroup(message.message,
                                                                                                      groupId: message.groupID,
                                                                                                      name: message.fromClientID,
                                                                                                      deviceId: UInt32(senderAccount.deviceId))
                                            let messageDecryption = String(data: decryptedData, encoding: .utf8)
                                            Debug.DLog("Message decryption: \(messageDecryption ?? "Empty error")")
                                            
                                            DispatchQueue.main.async {
                                                RealmManager.shared.realmGroups.updateLastMessage(groupID: message.groupID, lastMessage: decryptedData, lastMessageAt: message.createdAt, idLastMessage: message.id)
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
                                                completion?()
                                            }
                                            
                                            return
                                        } else {
                                            self.requestKeyInGroup(byGroupId: self.groupId, publication: message, completion: { post in
                                                self.messages.append(post)
                                                completion?()
                                            })
                                        }
                                    } else {
                                        self.requestKeyInGroup(byGroupId: self.groupId, publication: message, completion: { post in
                                            self.messages.append(post)
                                            completion?()
                                        })
                                    }
                                } catch {
                                    Debug.DLog("Decryption message error: \(error)")
                                    self.requestKeyInGroup(byGroupId: self.groupId, publication: message, completion: { post in
                                        self.messages.append(post)
                                        completion?()
                                    })
                                }
                            }
                        }
                    }
                    //                    self.reloadData()
                }
            }
        }
    }
    
    func didReceiveMessage(userInfo: [AnyHashable : Any]?, completion: (() -> ())? = nil) {
        if let userInfo = userInfo,
           let clientId = userInfo["clientId"] as? String,
           let publication = userInfo["publication"] as? Message_MessageObjectResponse,
           //            publication.groupID.isEmpty,
           clientId == self.clientId {
            
            if !RealmManager.shared.realmMessages.isExistMessage(msgId: publication.id){
                if let ourEncryptionMng = self.ourEncryptionManager {
                    do {
                        let decryptedData = try ourEncryptionMng.decryptFromAddress(publication.message,
                                                                                    name: clientId,
                                                                                    deviceId: UInt32(555))
                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
                        Debug.DLog("Message decryption: \(messageDecryption ?? "Empty error")")
                        
                        DispatchQueue.main.async {
                            let post = MessageModel(id: publication.id,
                                                    groupID: publication.groupID,
                                                    groupType: publication.groupType,
                                                    fromClientID: publication.fromClientID,
                                                    fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
                                                    clientID: publication.clientID,
                                                    message: decryptedData,
                                                    createdAt: publication.createdAt,
                                                    updatedAt: publication.updatedAt)
                            RealmManager.shared.realmMessages.add(message: post)
                            self.messages.append(post)
                            RealmManager.shared.realmGroups.updateLastMessage(groupID: publication.groupID, lastMessage: decryptedData, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                            completion?()
                        }
                    } catch {
                        //save message error when can't decrypt
                        DispatchQueue.main.async {
                            let messageError = "unable to decrypt this message".data(using: .utf8) ?? Data()
                            
                            let post = MessageModel(id: publication.id,
                                                    groupID: publication.groupID,
                                                    groupType: publication.groupType,
                                                    fromClientID: publication.fromClientID,
                                                    fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
                                                    clientID: publication.clientID,
                                                    message: messageError,
                                                    createdAt: publication.createdAt,
                                                    updatedAt: publication.updatedAt)
                            RealmManager.shared.realmMessages.add(message: post)
                            self.messages.append(post)
                            RealmManager.shared.realmGroups.updateLastMessage(groupID: publication.groupID, lastMessage: messageError, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                            completion?()
                        }
                        Debug.DLog("Decryption message error: \(error)")
                    }
                }
            }
        }
    }
    
    func decryptionMessage(publication: Message_MessageObjectResponse, completion: (() -> ())? = nil) {
        
        //        requestKeyInGroup(byGroupId: groupModel.groupID, publication: publication)
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
                                                                                  groupId: groupId,
                                                                                  name: publication.fromClientID,
                                                                                  deviceId: UInt32(senderAccount.deviceId))
                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
                        Debug.DLog("Message decryption: \(messageDecryption ?? "Empty error")")
                        
                        DispatchQueue.main.async {
                            let post = MessageModel(id: publication.id,
                                                    groupID: publication.groupID,
                                                    groupType: publication.groupType,
                                                    fromClientID: publication.fromClientID,
                                                    fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
                                                    clientID: publication.clientID,
                                                    message: decryptedData,
                                                    createdAt: publication.createdAt,
                                                    updatedAt: publication.updatedAt)
                            RealmManager.shared.realmMessages.add(message: post)
                            self.messages.append(post)
                            RealmManager.shared.realmGroups.updateLastMessage(groupID: self.groupId, lastMessage: decryptedData, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                            completion?()
                        }
                        
                        return
                    }else {
                        self.requestKeyInGroup(byGroupId: groupId, publication: publication, completion: { post in
                            self.messages.append(post)
                            completion?()
                        })
                    }
                }else {
                    self.requestKeyInGroup(byGroupId: groupId, publication: publication, completion: { post in
                        self.messages.append(post)
                        completion?()
                    })
                }
            } catch {
                Debug.DLog("Decryption message error: \(error)")
                self.requestKeyInGroup(byGroupId: groupId, publication: publication, completion: { post in
                    self.messages.append(post)
                    completion?()
                })
            }
            //            requestKeyInGroup(byGroupId: self.selectedRoom, publication: publication)
        }
    }
    
    func sendMessage(messageStr: String, completion: (() -> ())? = nil) {
        let messageStr = messageStr.trimmingCharacters(in: .whitespacesAndNewlines)
        if messageStr.isEmpty {
            return
        }
        
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        //        self.viewModel.requestBundleRecipient(byClientId: clientId) {
        
        //        }
        if isGroup {
            sendMessageGroup(payload: payload, completion: completion)
        } else {
            sendMessagePeer(payload: payload, completion: completion)
        }
    }
    
    private func sendMessagePeer(payload: Data, completion: (() -> ())? = nil) {
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            do {
                guard let encryptedData = try ourEncryptionManager?.encryptToAddress(payload,
                                                                                     name: clientId,
                                                                                     deviceId: self.recipientDeviceId) else { return }
                if groupId == 0, let group = RealmManager.shared.realmGroups.getGroup(clientId: clientId, type: groupType) {
                    groupId = group.groupID
                }
                if groupId == 0 {
                    createGroup(username: self.username, clientId: clientId) { (group) in
                        RealmManager.shared.realmGroups.add(group: group)
                        
                        Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, toClientId: self.clientId , groupId: group.groupID , groupType: "peer") { (result) in
                            if let result = result {
                                DispatchQueue.main.async {
                                    let post = MessageModel(id: result.id,
                                                            groupID: result.groupID,
                                                            groupType: result.groupType,
                                                            fromClientID: result.fromClientID,
                                                            fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: result.fromClientID, groupID: result.groupID),
                                                            clientID: result.clientID,
                                                            message: payload,
                                                            createdAt: result.createdAt,
                                                            updatedAt: result.updatedAt)
                                    RealmManager.shared.realmMessages.add(message: post)
                                    self.messages.append(post)
                                    Debug.DLog("Sent message \(post)")
                                    RealmManager.shared.realmGroups.updateLastMessage(groupID: result.groupID, lastMessage: payload, lastMessageAt: result.createdAt, idLastMessage: result.id)
                                    completion?()
                                }
                            }
                        }
                    }
                } else {
                    Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, toClientId: self.clientId , groupId: groupId , groupType: groupType) { (result) in
                        if let result = result {
                            DispatchQueue.main.async {
                                let post = MessageModel(id: result.id,
                                                        groupID: result.groupID,
                                                        groupType: result.groupType,
                                                        fromClientID: result.fromClientID,
                                                        fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: result.fromClientID, groupID: result.groupID),
                                                        clientID: result.clientID,
                                                        message: payload,
                                                        createdAt: result.createdAt,
                                                        updatedAt: result.updatedAt)
                                RealmManager.shared.realmMessages.add(message: post)
                                self.messages.append(post)
                                Debug.DLog("Sent message \(post)")
                                RealmManager.shared.realmGroups.updateLastMessage(groupID: result.groupID, lastMessage: payload, lastMessageAt: result.createdAt, idLastMessage: result.id)
                                completion?()
                            }
                        }
                    }
                }
                
            } catch {
                Debug.DLog("Send message error: \(error)")
            }
        }
    }
    
    func requestBundleRecipient(byClientId clientId: String,_ completion: @escaping () -> Void) {

        Backend.shared.authenticator
            .requestKey(byClientId: clientId) { [weak self](result, error, response) in
                
                guard let recipientResponse = response else {
                    print("Request prekey \(clientId) fail")
                    return
                }
                // check exist session recipient in database
//                if let ourAccountEncryptMng = self?.ourEncryptionManager {
                    self?.recipientDeviceId = UInt32(recipientResponse.deviceID)
//                    if !ourAccountEncryptMng.sessionRecordExistsForUsername(clientId, deviceId: 555) {
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
                                        
                                        let device = CKDevice(deviceId: NSNumber(value:555),
                                                              trustLevel: .trustedTofu,
                                                              parentKey: buddy.uniqueId,
                                                              parentCollection: CKBuddy.collection,
                                                              publicIdentityKeyData: nil,
                                                              lastSeenDate:nil)
                                        device.save(with:transaction)
                                    } else {
                                        myBuddy?.save(with: transaction)
                                        let device = CKDevice(deviceId: NSNumber(value:555),
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
                        // Case: 1 register user with server with publicKey, privateKey (preKey, signedPreKey)
                        self?.processKeyStoreHasPrivateKey(recipientResponse: recipientResponse)
                        
                        // Case: 2 register user with server with only publicKey (preKey, signedPreKey)
                        //                    self?.processKeyStoreOnlyPublicKey(recipientResponse: recipientResponse)
//                    }
//                    print("processPreKeyBundle recipient finished")
//                    completion()
//                } else {
//                    completion()
//                }
            }
        //        }
    }
    
    func processKeyStoreHasPrivateKey(recipientResponse: Signal_PeerGetClientKeyResponse) {
        if let ourEncryptionMng = self.ourEncryptionManager {
            do {
                let remotePrekey = try SignalPreKey.init(serializedData: recipientResponse.preKey)
                let remoteSignedPrekey = try SignalPreKey.init(serializedData: recipientResponse.signedPreKey)
                
                guard let preKeyKeyPair = remotePrekey.keyPair,
                      let signedPrekeyKeyPair = remoteSignedPrekey.keyPair else {
                    return
                }
                
                let signalPreKeyBundle = try SignalPreKeyBundle(registrationId: UInt32(recipientResponse.registrationID),
                                                                deviceId: UInt32(555),
                                                                preKeyId: UInt32(recipientResponse.preKeyID),
                                                                preKeyPublic: preKeyKeyPair.publicKey,
                                                                signedPreKeyId: UInt32(recipientResponse.signedPreKeyID),
                                                                signedPreKeyPublic: signedPrekeyKeyPair.publicKey,
                                                                signature: recipientResponse.signedPreKeySignature,
                                                                identityKey: recipientResponse.identityKeyPublic)
                
                let remoteAddress = SignalAddress(name: recipientResponse.clientID,
                                                  deviceId: 555)
                let remoteSessionBuilder = SignalSessionBuilder(address: remoteAddress,
                                                                context: ourEncryptionMng.signalContext)
                try remoteSessionBuilder.processPreKeyBundle(signalPreKeyBundle)
            } catch {
                Debug.DLog("processKeyStoreHasPrivateKey exception: \(error)")
            }
        }
    }
    
    private func sendMessageGroup(payload: Data, completion: (() -> ())? = nil) {
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            do {
                guard let encryptedData = try ourEncryptionManager?.encryptToGroup(payload,
                                                                                   groupId: groupId,
                                                                                   name: myAccount.username,
                                                                                   deviceId: UInt32(myAccount.deviceId)) else { return }
                Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, groupId: groupId, groupType: "group") { (result) in
                    if let result = result {
                        DispatchQueue.main.async {
                            let post = MessageModel(id: result.id,
                                                    groupID: result.groupID,
                                                    groupType: result.groupType,
                                                    fromClientID: result.fromClientID,
                                                    fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: result.fromClientID, groupID: result.groupID),
                                                    clientID: result.clientID,
                                                    message: payload,
                                                    createdAt: result.createdAt,
                                                    updatedAt: result.updatedAt)
                            RealmManager.shared.realmMessages.add(message: post)
                            self.messages.append(post)
                            Debug.DLog("Sent message: \(post) to group \(self.groupId)")
                            RealmManager.shared.realmGroups.updateLastMessage(groupID: result.groupID, lastMessage: payload, lastMessageAt: result.createdAt, idLastMessage: result.id)
                            completion?()
                        }
                    }
                }
            } catch {
                Debug.DLog("Send message error: \(error) to group \(self.groupId)")
            }
        }
    }
    
    func createGroup(username: String, clientId: String, completion: ((GroupModel) -> ())?) {
        guard let myAccount = CKSignalCoordinate.shared.myAccount else { return print("My Account is nil") }
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
                    completion?(group)
                }
            }
        }
    }
    
    func callPeerToPeer(group: GroupModel, clientId: String, callType type: Constants.CallType = .audio, completion: (() -> ())? = nil){
        if isRequesting { return }
        isRequesting = true
        requestVideoCall(isCallGroup: false, clientId: clientId, groupId: group.groupID, callType: type, completion: completion)
    }
    
    func callGroup(callType type: Constants.CallType = .audio, completion: (() -> ())? = nil){
        if isRequesting { return }
        isRequesting = true
        requestVideoCall(isCallGroup: true, clientId: clientId, groupId: groupId, callType: type, completion: completion)
    }
    
    private func requestVideoCall(isCallGroup: Bool ,clientId: String, groupId: Int64, callType type: Constants.CallType = .audio, completion: (() -> ())?) {
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
    
    func registerWithGroup(_ groupId: Int64) {
        if let group = RealmManager.shared.realmGroups.filterGroup(groupId: groupId) {
            if !group.isRegister {
                if let myAccount = CKSignalCoordinate.shared.myAccount , let ourAccountEncryptMng = self.ourEncryptionManager {
                    let userName = myAccount.username
                    let deviceID = Int32(555)
                    let address = SignalAddress(name: userName, deviceId: deviceID)
                    let groupSessionBuilder = SignalGroupSessionBuilder(context: ourAccountEncryptMng.signalContext)
                    let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
                    
                    do {
                        let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
                        Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                                   clientId: userName,
                                                                   deviceId: deviceID,
                                                                   senderKeyData: signalSKDM.serializedData()) { (result, error) in
                            print("Register group with result: \(result)")
                            if result {
                                RealmManager.shared.realmGroups.registerGroup(groupId: groupId)
                            }
                        }
                        
                    } catch {
                        print("Register group error: \(error)")
                        
                    }
                }
            }
        }
    }
    
    // Request key group
    func requestKeyInGroup(byGroupId groupId: Int64, publication: Message_MessageObjectResponse, completion: ((MessageModel) -> ())?) {
        Backend.shared.authenticator.requestKeyGroup(byClientId: publication.fromClientID,
                                                     groupId: groupId) {(result, error, response) in
            guard let groupResponse = response else {
                Debug.DLog("Request prekey \(groupId) fail")
                return
            }
            self.processSenderKey(byGroupId: groupResponse.groupID,
                                  responseSenderKey: groupResponse.clientKey)
            // decrypt message again
            self.decryptionMessage(groupId: groupResponse.groupID, publication: publication, completion: completion)
        }
    }
    
    private func processSenderKey(byGroupId groupId: Int64,
                          responseSenderKey: Signal_GroupClientKeyObject) {
        let deviceID = 444
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
    
    func decryptionMessage(groupId: Int64, publication: Message_MessageObjectResponse, completion: ((MessageModel) -> ())?) {
        
        //        requestKeyInGroup(byGroupId: groupModel.groupID, publication: publication)
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
                                                                                  groupId: groupId,
                                                                                  name: publication.fromClientID,
                                                                                  deviceId: UInt32(senderAccount.deviceId))
                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
                        print("Message decryption: \(messageDecryption ?? "Empty error")")
                        
                        DispatchQueue.main.async {
                            let post = MessageModel(id: publication.id,
                                                    groupID: publication.groupID,
                                                    groupType: publication.groupType,
                                                    fromClientID: publication.fromClientID,
                                                    fromDisplayName: RealmManager.shared.realmGroups.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
                                                    clientID: publication.clientID,
                                                    message: decryptedData,
                                                    createdAt: publication.createdAt,
                                                    updatedAt: publication.updatedAt)
                            RealmManager.shared.realmMessages.add(message: post)
                            RealmManager.shared.realmGroups.updateLastMessage(groupID: groupId, lastMessage: decryptedData, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                            completion?(post)
                        }
                        
                        return
                    }else {
                        requestKeyInGroup(byGroupId: groupId, publication: publication, completion: completion)
                    }
                }else {
                    requestKeyInGroup(byGroupId: groupId, publication: publication, completion: completion)
                }
            } catch {
                print("Decryption message error: \(error)")
                requestKeyInGroup(byGroupId: groupId, publication: publication, completion: completion)
            }
            //            requestKeyInGroup(byGroupId: self.selectedRoom, publication: publication)
        }
    }
}
