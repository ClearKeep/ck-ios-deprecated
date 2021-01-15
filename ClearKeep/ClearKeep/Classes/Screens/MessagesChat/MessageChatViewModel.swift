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
    var ourEncryptionManager: CKAccountSignalEncryptionManager?
    var isRequesting = false
    var groupId: Int64 = 0
    var clientId: String = ""
    var username: String = ""
    var groupType: String = "peer"
    @Published var recipientDeviceId: UInt32 = 0
    
    init() {
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
    }
    
//    init(clientId: String, username: String = "", groupId: Int64 = 0, groupType: String) {
//        self.groupId = groupId
//        self.clientId = clientId
//        self.username = username
//        self.groupType = groupType
//        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
//    }
    
    func setup(clientId: String, username: String = "", groupId: Int64 = 0, groupType: String) {
        self.groupId = groupId
        self.clientId = clientId
        self.username = username
        self.groupType = groupType
    }
    
    func callPeerToPeer(group: GroupModel){
        if isRequesting { return }
        isRequesting = true
        requestVideoCall(clientId: clientId, groupId: group.groupID, groupToken: group.groupToken)
    }
    
    func requestVideoCall(clientId: String, groupId: Int64, groupToken: String) {
        Backend.shared.videoCall(clientId, groupId) { (response, error) in
            self.isRequesting = false
            if let response = response {
                if response.success {
                    DispatchQueue.main.async {
                        AVCaptureDevice.authorizeVideo(completion: { (status) in
                            AVCaptureDevice.authorizeAudio(completion: { (status) in
                                if status == .alreadyAuthorized || status == .justAuthorized {
                                    CallManager.shared.startCall(clientId: clientId,
                                                                 clientName: self.username,
                                                                 avatar: "",
                                                                 groupId: groupId,
                                                                 groupToken: groupToken)
                                }
                            })
                        })
                    }
                }
            }
        }
    }
    
    func createGroup(username: String, clientId: String, completion: ((GroupModel) -> ())?) {
        guard let myAccount = CKSignalCoordinate.shared.myAccount else { return print("My Account is nil") }
        var req = Group_CreateGroupRequest()
        let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserNameLogin) ?? "") as String
        req.groupName = "\(username)-\(userNameLogin)"
        req.groupType = "peer"
        req.createdByClientID = myAccount.username
        req.lstClientID = [myAccount.username , clientId]
        
        Backend.shared.createRoom(req) { (result) in
            let lstClientID = result.lstClient.map{$0.id}
            
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
                                       lastMessage: Data())
                self.groupId = group.groupID
                completion?(group)
            }
        }
    }
    
    func requestBundleRecipient(byClientId clientId: String) {
        
        //        let realm = RealmHelper<DeviceIdForClientId>()
        //        let lstDeviceId = realm.findAll()
        //        if let existDevice = lstDeviceId.filter({$0.clientId == clientId}).first {
        //            DispatchQueue.main.async {
        //                self.recipientDeviceId = UInt32(existDevice.recipient)
        //            }
        //        } else {
        Backend.shared.authenticator
            .requestKey(byClientId: clientId) { [weak self](result, error, response) in
                
                guard let recipientResponse = response else {
                    print("Request prekey \(clientId) fail")
                    return
                }
                // check exist session recipient in database
                if let ourAccountEncryptMng = self?.ourEncryptionManager {
                    self?.recipientDeviceId = UInt32(555)
                    //                        DispatchQueue.main.async {
                    //                            self?.recipientDeviceId = UInt32(recipientResponse.deviceID)
                    //                            let realmDevice = DeviceIdForClientId()
                    //                            realmDevice.clientId = clientId
                    //                            realmDevice.recipient = recipientResponse.deviceID
                    //                            realm.add(object: realmDevice)
                    //                        }
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
                
                let bundle = CKBundle(deviceId: UInt32(555),
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
}
