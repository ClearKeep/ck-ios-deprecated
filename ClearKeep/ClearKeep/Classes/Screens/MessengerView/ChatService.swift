//
//  ChatService.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/24/21.
//

import Foundation

final class ChatService {
    
    // MARK: - Singleton
    static let shared = ChatService()
    
    // MARK: - Constants
    private let connectionDb = CKDatabaseManager.shared.database?.newConnection()
    
    // MARK: - Variables
    private(set) var openedGroupId: Int64 = 0
 
    // MARK: - Init & Setter
    private init() { }
    
    func setOpenedGroupId(_ groupId: Int64) {
        openedGroupId = groupId
    }
}

// MARK: - Peer
extension ChatService {
    func sendMessageToPeer(toClientId: String, groupId: Int64, messageData: Data, isForceProcessKey: Bool = false, completion: ((MessageModel) -> ())?) {
        let fromClientId = getClientId()
        
        if isForceProcessKey {
            requestKeyPeer(byClientId: toClientId, completion: { isSuccess in
                if isSuccess {
                    self.sendMessageToPeer(toClientId: toClientId, groupId: groupId, messageData: messageData, completion: completion)
                } else {
                    Debug.DLog("Send message fail - Can't request key peer")
                    return
                }
            })
            return
        }
        
        do {
            guard let encryptedData = try CKSignalCoordinate.shared.ourEncryptionManager?.encryptToAddress(messageData,
                                                                                 name: toClientId) else
            { return }
            print(String(decoding: encryptedData.data.base64EncodedData(), as: UTF8.self))
            Backend.shared.send(encryptedData.data, fromClientId: fromClientId, toClientId: toClientId , groupId: groupId , groupType: "peer") { (publication) in
                if let publication = publication {
                    completion?(self.saveNewMessage(publication: publication, message: messageData))
                }
            }
        } catch {
            Debug.DLog("Send message fail - \(error.localizedDescription)")
        }
    }
    
    func decryptMessageFromPeer(_ publication: Message_MessageObjectResponse, completion: ((MessageModel) -> ())? = nil) {
        do {
            if let ourEncryptionMng = CKSignalCoordinate.shared.ourEncryptionManager {
                let messageDecrypted = try ourEncryptionMng.decryptFromAddress(publication.message,
                                                                               name: publication.fromClientID)
                completion?(saveNewMessage(publication: publication, message: messageDecrypted))
            } else {
                completion?(saveNewMessage(publication: publication, message: getUnableErrorMessage(message: nil)))
            }
        } catch {
            completion?(saveNewMessage(publication: publication, message: getUnableErrorMessage(message: error.localizedDescription)))
        }
    }
    
    func requestKeyPeer(byClientId clientId: String, completion: @escaping (Bool) -> Void) {
        Backend.shared.authenticator
            .requestKey(byClientId: clientId) { [weak self] (result, error, response) in
                
                guard let recipientResponse = response else {
                    Debug.DLog("Request prekey \(clientId) fail")
                    completion(false)
                    return
                }
//                self?.recipientDeviceId = UInt32(recipientResponse.deviceID)
                
                if let connectionDb = self?.connectionDb,
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
                                
                                let device = CKDevice(deviceId: NSNumber(value: Constants.encryptedDeviceId),
                                                      trustLevel: .trustedTofu,
                                                      parentKey: buddy.uniqueId,
                                                      parentCollection: CKBuddy.collection,
                                                      publicIdentityKeyData: nil,
                                                      lastSeenDate:nil)
                                device.save(with:transaction)
                            } else {
                                myBuddy?.save(with: transaction)
                                let device = CKDevice(deviceId: NSNumber(value: Constants.encryptedDeviceId),
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
                self?.processKeyStoreHasPrivateKey(recipientResponse: recipientResponse)
                
                completion(true)
            }
    }
    
    private func processKeyStoreHasPrivateKey(recipientResponse: Signal_PeerGetClientKeyResponse) {
        if let ourEncryptionMng = CKSignalCoordinate.shared.ourEncryptionManager {
            do {
                let remotePrekey = try SignalPreKey(serializedData: recipientResponse.preKey)
                let remoteSignedPrekey = try SignalSignedPreKey(serializedData: recipientResponse.signedPreKey)
                
                guard let preKeyKeyPair = remotePrekey.keyPair,
                      let signedPrekeyKeyPair = remoteSignedPrekey.keyPair else {
                    return
                }
                
                let signalPreKeyBundle = try SignalPreKeyBundle(registrationId: UInt32(recipientResponse.registrationID),
                                                                deviceId: UInt32(Constants.encryptedDeviceId),
                                                                preKeyId: UInt32(recipientResponse.preKeyID),
                                                                preKeyPublic: preKeyKeyPair.publicKey,
                                                                signedPreKeyId: UInt32(recipientResponse.signedPreKeyID),
                                                                signedPreKeyPublic: signedPrekeyKeyPair.publicKey,
                                                                signature: recipientResponse.signedPreKeySignature,
                                                                identityKey: recipientResponse.identityKeyPublic)
                
                let remoteAddress = SignalAddress(name: recipientResponse.clientID,
                                                  deviceId: Constants.encryptedDeviceId)
                try ourEncryptionMng.consumeIncoming(remoteAddress, signalPreKeyBundle: signalPreKeyBundle)
            } catch {
                Debug.DLog("processKeyStoreHasPrivateKey exception: \(error)")
            }
        }
    }
    
    func createPeerGroup(receiveId: String, completion: ((GroupModel) -> ())?) {
        guard let user = Backend.shared.getUserLogin() else {
            Debug.DLog("My Account is nil")
            return
        }
        var req = Group_CreateGroupRequest()
        req.groupName = "\(user.displayName)-\(user.id)"
        req.groupType = "peer"
        req.createdByClientID = user.id
        req.lstClientID = [user.id , receiveId]
        
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
                    completion?(group)
                }
            }
        }
    }
}

// MARK: - Group
extension ChatService {
    func sendMessageToGroup(groupId: Int64, messageData: Data,completion: ((MessageModel) -> ())?) {
        do {
            let fromClientId = getClientId()
            guard let encryptedData = try CKSignalCoordinate.shared.ourEncryptionManager?.encryptToGroup(messageData,
                                                                               groupId: groupId,
                                                                               name: fromClientId) else { return }
            Backend.shared.send(encryptedData.data, fromClientId: fromClientId, groupId: groupId, groupType: "group") { (publication) in
                if let publication = publication {
                    completion?(self.saveNewMessage(publication: publication, message: messageData))
                }
            }
        } catch {
            Debug.DLog("Send message error: \(error) to group \(groupId)")
        }
    }
    
    func decryptMessageFromGroup(_ publication: Message_MessageObjectResponse, completion: ((MessageModel) -> ())? = nil) {
        do {
            if let ourEncryptionMng = CKSignalCoordinate.shared.ourEncryptionManager,
               ourEncryptionMng.senderKeyExistsForUsername(publication.fromClientID, deviceId: Constants.decryptedDeviceId, groupId: publication.groupID) {
                let messageDecrypted = try ourEncryptionMng.decryptFromGroup(publication.message,
                                                                             groupId: publication.groupID,
                                                                             name: publication.fromClientID)
                completion?(self.saveNewMessage(publication: publication, message: messageDecrypted))
            } else {
                requestKeyInGroup(byGroupId: publication.groupID, fromClientId: publication.fromClientID) { isSuccess in
                    if isSuccess {
                        self.decryptMessageFromGroup(publication, completion: completion)
                    } else {
                        completion?(self.saveNewMessage(publication: publication, message: self.getUnableErrorMessage(message: nil)))
                    }
                }
            }
        } catch {
            requestKeyInGroup(byGroupId: publication.groupID, fromClientId: publication.fromClientID) { isSuccess in
                if isSuccess {
                    self.decryptMessageFromGroup(publication, completion: completion)
                } else {
                    completion?(self.saveNewMessage(publication: publication, message: self.getUnableErrorMessage(message: error.localizedDescription)))
                }
            }
        }
    }
    
    func registerWithGroup(_ groupId: Int64, completion: @escaping (Bool) -> ()) {
        if let group = RealmManager.shared.getGroup(by: groupId) {
            if !group.isRegistered && !getClientId().isEmpty{
                if  let ourAccountEncryptMng = CKSignalCoordinate.shared.ourEncryptionManager {
                    let address = SignalAddress(name: getClientId(), deviceId: Constants.encryptedDeviceId)
                    let groupSessionBuilder = SignalGroupSessionBuilder(context: ourAccountEncryptMng.signalContext)
                    let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
                    
                    do {
                        let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
                        Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                                   clientId: address.name,
                                                                   deviceId: address.deviceId,
                                                                   senderKeyData: signalSKDM.serializedData()) { (result, error) in
                            if result {
                                RealmManager.shared.registerGroup(by: groupId)
                                completion(true)
                            }
                            completion(false)
                            Debug.DLog("Register group \(groupId) with result: \(result)")
                        }
                        
                    } catch {
                        completion(false)
                        Debug.DLog("Register group \(groupId) error: \(error)")
                    }
                }
            }
        }
    }
    
    // Request key group
    func requestKeyInGroup(byGroupId groupId: Int64, fromClientId: String, completion: @escaping ((Bool) -> ())) {
        Backend.shared.authenticator.requestKeyGroup(byClientId: fromClientId,
                                                     groupId: groupId) {(result, error, response) in
            guard let groupResponse = response else {
                Debug.DLog("Request prekey \(groupId) fail")
                completion(false)
                return
            }
            self.processSenderKey(byGroupId: groupResponse.groupID,
                                  responseSenderKey: groupResponse.clientKey)
            // decrypt message again
            completion(true)
        }
    }
    
    private func processSenderKey(byGroupId groupId: Int64,
                          responseSenderKey: Signal_GroupClientKeyObject) {
        if let ourEncryptionMng = CKSignalCoordinate.shared.ourEncryptionManager,
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
                let remoteAddress = SignalAddress(name: responseSenderKey.clientID,
                                             deviceId: Constants.decryptedDeviceId)
                
                try ourEncryptionMng.consumeIncoming(toGroup: groupId,
                                                         address: remoteAddress,
                                                         skdmDtata: responseSenderKey.clientKeyDistribution)
            } catch {
                Debug.DLog("processSenderKey error: \(error)")
            }
        }
    }
}

// MARK: - Private function
extension ChatService {
    private func getUnableErrorMessage(message: String?) -> Data {
        var errorMessage = "Unable to decrypt this message"
        if (AppConfig.buildEnvironment == .development) {
            errorMessage =  message ?? "Unable to decrypt this message"
        }
        return errorMessage.data(using: .utf8) ?? Data()
    }
    
    private func saveNewMessage(publication: Message_MessageObjectResponse, message: Data) -> MessageModel {
        let messageRecord = MessageModel(id: publication.id,
                                groupID: publication.groupID,
                                groupType: publication.groupType,
                                fromClientID: publication.fromClientID,
                                clientID: publication.clientID,
                                message: message,
                                createdAt: publication.createdAt,
                                updatedAt: publication.updatedAt)
        RealmManager.shared.updateLastMessage(messageRecord)
        
        return messageRecord
    }
    
    private func getClientId() -> String {
        return CKSignalCoordinate.shared.myAccount?.username ?? ""
    }
}

// Notification
extension ChatService {
    class PublicationNotification: Codable {
        var id: String
        var clientId: String
        var fromClientId: String
        var groupId: Int64
        var groupType: String
        var message: Data
        var createdAt: Int64
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case clientId = "client_id"
            case fromClientId = "from_client_id"
            case groupId = "group_id"
            case groupType = "group_type"
            case message = "message"
            case createdAt = "created_at"
        }
        
        required init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            clientId = try container.decode(String.self, forKey: .clientId)
            fromClientId = try container.decode(String.self, forKey: .fromClientId)
            groupId = try container.decode(Int64.self, forKey: .groupId)
            groupType = try container.decode(String.self, forKey: .groupType)
            message = try Data(base64Encoded: container.decode(String.self, forKey: .message).data(using: .utf8) ?? Data()) ?? Data()
            createdAt = try container.decode(Int64.self, forKey: .createdAt)
        }
    }
    
    func decryptMessageFromPeer(_ publication: PublicationNotification, completion: ((MessageModel) -> ())? = nil) {
        do {
            if let ourEncryptionMng = CKSignalCoordinate.shared.ourEncryptionManager {
                let messageDecrypted = try ourEncryptionMng.decryptFromAddress(publication.message,
                                                                               name: publication.fromClientId)
                completion?(saveNewMessage(publication: publication, message: messageDecrypted))
            } else {
                completion?(self.saveNewMessage(publication: publication, message: getUnableErrorMessage(message: nil)))
            }
        } catch {
            completion?(self.saveNewMessage(publication: publication, message: getUnableErrorMessage(message: error.localizedDescription)))
        }
    }
    
    func decryptMessageFromGroup(_ publication: PublicationNotification, completion: ((MessageModel) -> ())? = nil) {
        do {
            if let ourEncryptionMng = CKSignalCoordinate.shared.ourEncryptionManager,
               ourEncryptionMng.senderKeyExistsForUsername(publication.fromClientId, deviceId: Constants.decryptedDeviceId, groupId: publication.groupId) {
                let messageDecrypted = try ourEncryptionMng.decryptFromGroup(publication.message,
                                                                             groupId: publication.groupId,
                                                                             name: publication.fromClientId)
                completion?(saveNewMessage(publication: publication, message: messageDecrypted))
            } else {
                requestKeyInGroup(byGroupId: publication.groupId, fromClientId: publication.fromClientId) { isSuccess in
                    if isSuccess {
                        self.decryptMessageFromGroup(publication, completion: completion)
                    } else {
                        completion?(self.saveNewMessage(publication: publication, message: self.getUnableErrorMessage(message: nil)))
                    }
                }
            }
        } catch {
            requestKeyInGroup(byGroupId: publication.groupId, fromClientId: publication.fromClientId) { isSuccess in
                if isSuccess {
                    self.decryptMessageFromGroup(publication, completion: completion)
                } else {
                    completion?(self.saveNewMessage(publication: publication, message: self.getUnableErrorMessage(message: error.localizedDescription)))
                }
            }
        }
    }
    
    private func saveNewMessage(publication: PublicationNotification, message: Data) -> MessageModel {
        let messageRecord = MessageModel(id: publication.id,
                                groupID: publication.groupId,
                                groupType: publication.groupType,
                                fromClientID: publication.fromClientId,
                                clientID: publication.clientId,
                                message: message,
                                createdAt: publication.createdAt,
                                updatedAt: publication.createdAt)
        RealmManager.shared.updateLastMessage(messageRecord)
        
        return messageRecord
    }
}
