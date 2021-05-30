////
////  ChatService.swift
////  ClearKeep
////
////  Created by Nguyễn Nam on 5/24/21.
////
//
//import Foundation
//
//final class ChatService {
//    
//    // MARK: - Singleton
//    static let shared = ChatService()
//    
//    // MARK: - Constants
//    private let connectionDb = CKDatabaseManager.shared.database?.newConnection()
//    
//    // MARK: - Variables
//    private(set) var ourEncryptionManager: CKAccountSignalEncryptionManager?
//    private(set) var recipientDeviceId: UInt32 = 0
// 
//    private init() {
//        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
//    }
//    
//    // MARK: - Peer
//    // Register key peer to peer
//    private func requestBundleRecipient(byClientId clientId: String,_ completion: @escaping () -> Void) {
//        Backend.shared.authenticator
//            .requestKey(byClientId: clientId) { [weak self] (result, error, response) in
//                
//                guard let recipientResponse = response else {
//                    Debug.DLog("Request prekey \(clientId) fail")
//                    return
//                }
//                //                // check exist session recipient in database
//                //                //                if let ourAccountEncryptMng = self?.ourEncryptionManager {
//                self?.recipientDeviceId = UInt32(recipientResponse.deviceID)
//                //                //                    if !ourAccountEncryptMng.sessionRecordExistsForUsername(clientId, deviceId: 555) {
//                if let connectionDb = self?.connectionDb,
//                   let myAccount = CKSignalCoordinate.shared.myAccount {
//                    // save devcice by recipient account
//                    connectionDb.readWrite ({ (transaction) in
//                        if let _ = myAccount.refetch(with: transaction) {
//                            let myBuddy = CKBuddy.fetchBuddy(username: recipientResponse.clientID,
//                                                             accountUniqueId: myAccount.uniqueId,
//                                                             transaction: transaction)
//                            if myBuddy == nil {
//                                let buddy = CKBuddy()!
//                                buddy.accountUniqueId = myAccount.uniqueId
//                                buddy.username = recipientResponse.clientID
//                                buddy.save(with:transaction)
//                                
//                                let device = CKDevice(deviceId: NSNumber(value:555),
//                                                      trustLevel: .trustedTofu,
//                                                      parentKey: buddy.uniqueId,
//                                                      parentCollection: CKBuddy.collection,
//                                                      publicIdentityKeyData: nil,
//                                                      lastSeenDate:nil)
//                                device.save(with:transaction)
//                            } else {
//                                myBuddy?.save(with: transaction)
//                                let device = CKDevice(deviceId: NSNumber(value:555),
//                                                      trustLevel: .trustedTofu,
//                                                      parentKey: myBuddy!.uniqueId,
//                                                      parentCollection: CKBuddy.collection,
//                                                      publicIdentityKeyData: nil,
//                                                      lastSeenDate:nil)
//                                device.save(with:transaction)
//                            }
//                        }
//                    })
//                }
//                //                    // Case: 1 register user with server with publicKey, privateKey (preKey, signedPreKey)
////                self?.processKeyStoreHasPrivateKey(recipientResponse: recipientResponse)
//                //
//                //                    // Case: 2 register user with server with only publicKey (preKey, signedPreKey)
//                                    //                                            self?.processKeyStoreOnlyPublicKey(recipientResponse: recipientResponse)
//                //                    //                    }
//                //                    print("processPreKeyBundle recipient finished")
//                completion()
//                //                }
//                //                    completion()
//                //                }
//            }
//        //        }
//    }
//    
//    private func processKeyStoreHasPrivateKey(recipientResponse: Signal_PeerGetClientKeyResponse) {
//        if let ourEncryptionMng = self.ourEncryptionManager {
//            do {
//                let remotePrekey = try SignalPreKey.init(serializedData: recipientResponse.preKey)
//                let remoteSignedPrekey = try SignalPreKey.init(serializedData: recipientResponse.signedPreKey)
//                
//                guard let preKeyKeyPair = remotePrekey.keyPair,
//                      let signedPrekeyKeyPair = remoteSignedPrekey.keyPair else {
//                    return
//                }
//                
//                let signalPreKeyBundle = try SignalPreKeyBundle(registrationId: UInt32(recipientResponse.registrationID),
//                                                                deviceId: UInt32(555),
//                                                                preKeyId: UInt32(recipientResponse.preKeyID),
//                                                                preKeyPublic: preKeyKeyPair.publicKey,
//                                                                signedPreKeyId: UInt32(recipientResponse.signedPreKeyID),
//                                                                signedPreKeyPublic: signedPrekeyKeyPair.publicKey,
//                                                                signature: recipientResponse.signedPreKeySignature,
//                                                                identityKey: recipientResponse.identityKeyPublic)
//                
//                let remoteAddress = SignalAddress(name: recipientResponse.clientID,
//                                                  deviceId: 555)
//                let remoteSessionBuilder = SignalSessionBuilder(address: remoteAddress,
//                                                                context: ourEncryptionMng.signalContext)
//                try remoteSessionBuilder.processPreKeyBundle(signalPreKeyBundle)
//            } catch {
//                Debug.DLog("processKeyStoreHasPrivateKey exception: \(error)")
//            }
//        }
//    }
//    
//    private func processKeyStoreOnlyPublicKey(recipientResponse: Signal_PeerGetClientKeyResponse) {
//        if let ourEncryptionMng = self.ourEncryptionManager {
//            do {
//                let ckSignedPreKey = CKSignedPreKey(withPreKeyId: UInt32(recipientResponse.signedPreKeyID),
//                                                    publicKey: recipientResponse.signedPreKey,
//                                                    signature: recipientResponse.signedPreKeySignature)
//                let ckPreKey = CKPreKey(withPreKeyId: UInt32(recipientResponse.preKeyID),
//                                        publicKey: recipientResponse.preKey)
//                
//                let bundle = CKBundle(deviceId: UInt32(555),
//                                      registrationId: UInt32(recipientResponse.registrationID),
//                                      identityKey: recipientResponse.identityKeyPublic,
//                                      signedPreKey: ckSignedPreKey,
//                                      preKeys: [ckPreKey])
//                try ourEncryptionMng.consumeIncomingBundle(recipientResponse.clientID, bundle: bundle)
//            } catch {
//                Debug.DLog("processKeyStoreOnlyPublicKey exception: \(error)")
//            }
//        }
//    }
//    
//    // MARK: - Group
//    func registerWithGroup(_ groupId: Int64) {
//        if let group = RealmManager.shared.realmGroups.filterGroup(groupId: groupId) {
//            if !group.isRegister {
//                if let myAccount = CKSignalCoordinate.shared.myAccount , let ourAccountEncryptMng = self.ourEncryptionManager {
//                    let userName = myAccount.username
//                    let deviceID = Int32(555)
//                    let address = SignalAddress(name: userName, deviceId: deviceID)
//                    let groupSessionBuilder = SignalGroupSessionBuilder(context: ourAccountEncryptMng.signalContext)
//                    let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
//                    
//                    do {
//                        let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
//                        Backend.shared.authenticator.registerGroup(byGroupId: groupId,
//                                                                   clientId: userName,
//                                                                   deviceId: deviceID,
//                                                                   senderKeyData: signalSKDM.serializedData()) { (result, error) in
//                            print("Register group with result: \(result)")
//                            if result {
//                                RealmManager.shared.realmGroups.registerGroup(groupId: groupId)
//                            }
//                        }
//                        
//                    } catch {
//                        print("Register group error: \(error)")
//                        
//                    }
//                }
//            }
//        }
//    }
//    
//    // Request key group
//    func requestKeyInGroup(byGroupId groupId: Int64, publication: Message_MessageObjectResponse, completion: ((MessageModel) -> ())?) {
//        Backend.shared.authenticator.requestKeyGroup(byClientId: publication.fromClientID,
//                                                     groupId: groupId) {(result, error, response) in
//            guard let groupResponse = response else {
//                Debug.DLog("Request prekey \(groupId) fail")
//                return
//            }
//            self.processSenderKey(byGroupId: groupResponse.groupID,
//                                  responseSenderKey: groupResponse.clientKey)
//            // decrypt message again
//            self.decryptionMessage(groupId: groupResponse.groupID, publication: publication, completion: completion)
//        }
//    }
//    
//    private func processSenderKey(byGroupId groupId: Int64,
//                          responseSenderKey: Signal_GroupClientKeyObject) {
//        let deviceID = 444
//        if let ourAccountEncryptMng = self.ourEncryptionManager,
//           let connectionDb = self.connectionDb {
//            // save account infor
//            connectionDb.readWrite { (transaction) in
//                var account = CKAccount.allAccounts(withUsername: responseSenderKey.clientID, transaction: transaction).first
//                if account == nil {
//                    account = CKAccount(username: responseSenderKey.clientID, deviceId: Int32(deviceID), accountType: .none)
//                    account?.save(with: transaction)
//                }
//            }
//            do {
//                let addresss = SignalAddress(name: responseSenderKey.clientID,
//                                             deviceId: Int32(deviceID))
//                try ourAccountEncryptMng.consumeIncoming(toGroup: groupId,
//                                                         address: addresss,
//                                                         skdmDtata: responseSenderKey.clientKeyDistribution)
//            } catch {
//                Debug.DLog("processSenderKey error: \(error)")
//            }
//        }
//    }
//    
//    func decryptionMessage(groupId: Int64, publication: Message_MessageObjectResponse, completion: ((MessageModel) -> ())?) {
//        
//        //        requestKeyInGroup(byGroupId: groupModel.groupID, publication: publication)
//        if let ourEncryptionMng = self.ourEncryptionManager,
//           let connectionDb = self.connectionDb {
//            do {
//                var account: CKAccount?
//                connectionDb.read { (transaction) in
//                    account = CKAccount.allAccounts(withUsername: publication.fromClientID, transaction: transaction).first
//                }
//                if let senderAccount = account {
//                    if ourEncryptionMng.senderKeyExistsForUsername(publication.fromClientID, deviceId: senderAccount.deviceId, groupId: groupId) {
//                        let decryptedData = try ourEncryptionMng.decryptFromGroup(publication.message,
//                                                                                  groupId: groupId,
//                                                                                  name: publication.fromClientID,
//                                                                                  deviceId: UInt32(senderAccount.deviceId))
//                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
//                        print("Message decryption: \(messageDecryption ?? "Empty error")")
//                        
//                        DispatchQueue.main.async {
//                            let post = MessageModel(id: publication.id,
//                                                    groupID: publication.groupID,
//                                                    groupType: publication.groupType,
//                                                    fromClientID: publication.fromClientID,
//                                                    fromDisplayName: RealmManager.shared.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
//                                                    clientID: publication.clientID,
//                                                    message: decryptedData,
//                                                    createdAt: publication.createdAt,
//                                                    updatedAt: publication.updatedAt)
//                            RealmManager.shared.realmMessages.add(message: post)
//                            RealmManager.shared.realmGroups.updateLastMessage(groupID: groupId, lastMessage: decryptedData, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
//                            completion?(post)
//                        }
//                        
//                        return
//                    }else {
//                        requestKeyInGroup(byGroupId: groupId, publication: publication, completion: completion)
//                    }
//                }else {
//                    requestKeyInGroup(byGroupId: groupId, publication: publication, completion: completion)
//                }
//            } catch {
//                print("Decryption message error: \(error)")
//                requestKeyInGroup(byGroupId: groupId, publication: publication, completion: completion)
//            }
//            //            requestKeyInGroup(byGroupId: self.selectedRoom, publication: publication)
//        }
//    }
//    
//}
