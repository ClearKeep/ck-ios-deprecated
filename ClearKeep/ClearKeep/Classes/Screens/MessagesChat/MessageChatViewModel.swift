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
    var ourEncryptionManager: CKAccountSignalEncryptionManager?
    var recipientDeviceId: UInt32 = 0
    @Published var messages: [MessageModel] = []
    
    init(clientId: String) {
        self.clientId = clientId
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
        requestBundleRecipient(byClientId: clientId)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMessage),
                                               name: NSNotification.Name("DidReceiveMessage"),
                                               object: nil)
    }
    
    @objc func didReceiveMessage(notification: NSNotification) {
        print("didReceiveMessage \(String(describing: notification.userInfo))")
        if let userInfo = notification.userInfo,
           let clientId = userInfo["clientId"] as? String,
           let publication = userInfo["publication"] as? Signalc_Publication,
           clientId == self.clientId {
            if let ourEncryptionMng = self.ourEncryptionManager {
                do {
                    let decryptedData = try ourEncryptionMng.decryptFromAddress(publication.message,
                                                                                     name: clientId,
                                                                                     deviceId: recipientDeviceId)
                    let messageDecryption = String(data: decryptedData, encoding: .utf8)
                    print("Message decryption: \(messageDecryption ?? "Empty error")")

                } catch {
                    print("Decryption message error: \(error)")
                }
            }
        }
    }
    
    func requestBundleRecipient(byClientId clientId: String) {
        Backend.shared.authenticator.requestKey(byClientID: clientId) { [weak self](result, error, response) in
            
            guard let recipientStore = response else {
                print("Request prekey \(clientId) fail")
                return
            }
            // create CKBundle
            do {
                if let ourEncryptionMng = self?.ourEncryptionManager,
                   let connectionDb = CKDatabaseManager.shared.database?.newConnection(),
                   let myAccount = CKSignalCoordinate.shared.myAccount {
                    self?.recipientDeviceId = UInt32(recipientStore.deviceID)
                    // save devcice by recipient account
                    connectionDb.readWrite ({ (transaction) in
                        if let _ = myAccount.refetch(with: transaction) {
                            let buddy = CKBuddy()!
                            buddy.accountUniqueId = myAccount.uniqueId
                            buddy.username = recipientStore.clientID
                            buddy.save(with:transaction)
                            
                            let device = CKDevice(deviceId: NSNumber(value:recipientStore.deviceID),
                                                  trustLevel: .trustedTofu,
                                                  parentKey: buddy.uniqueId,
                                                  parentCollection: CKBuddy.collection,
                                                  publicIdentityKeyData: nil,
                                                  lastSeenDate:nil)
                            device.save(with:transaction)
                        }
                    })
                    
                    // Case: 1
//                    let remotePrekey = try SignalPreKey.init(serializedData: recipientStore.preKey)
//                    let remoteSignedPrekey = try SignalPreKey.init(serializedData: recipientStore.signedPreKey)
//
//                    guard let preKeyKeyPair = remotePrekey.keyPair, let signedPrekeyKeyPair = remoteSignedPrekey.keyPair else {
//                        return
//                    }
//
//                    let signalPreKeyBundle = try SignalPreKeyBundle(registrationId: UInt32(recipientStore.registrationID),
//                                                                    deviceId: UInt32(recipientStore.deviceID),
//                                                                    preKeyId: UInt32(recipientStore.preKeyID),
//                                                                    preKeyPublic: preKeyKeyPair.publicKey,
//                                                                    signedPreKeyId: UInt32(recipientStore.signedPreKeyID),
//                                                                    signedPreKeyPublic: signedPrekeyKeyPair.publicKey,
//                                                                    signature: recipientStore.signedPreKeySignature,
//                                                                    identityKey: recipientStore.identityKeyPublic)
//
//
//                    let remoteAddress = SignalAddress(name: recipientStore.clientID,
//                                                      deviceId: recipientStore.deviceID)
//                    let remoteSessionBuilder = SignalSessionBuilder(address: remoteAddress,
//                                                                    context: ourEncryptionMng.signalContext)
//                    try remoteSessionBuilder.processPreKeyBundle(signalPreKeyBundle)
                    
                    // Case: 2
                    let ckSignedPreKey = CKSignedPreKey(withPreKeyId: UInt32(recipientStore.signedPreKeyID),
                                                             publicKey: recipientStore.signedPreKey,
                                                             signature: recipientStore.signedPreKeySignature)
                    let ckPreKey = CKPreKey(withPreKeyId: UInt32(recipientStore.preKeyID),
                                            publicKey: recipientStore.preKey)

                    let bundle = CKBundle(deviceId: UInt32(recipientStore.deviceID),
                                          registrationId: UInt32(recipientStore.registrationID),
                                              identityKey: recipientStore.identityKeyPublic,
                                              signedPreKey: ckSignedPreKey,
                                              preKeys: [ckPreKey])
                    try ourEncryptionMng.consumeIncomingBundle(recipientStore.clientID, bundle: bundle)
                    print("processPreKeyBundle recipient finish")
                }
            } catch {
                print("requestBundleRecipient Error: \(error)")
            }
        }
    }
    
    func send(messageStr: String) {
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        let post = MessageModel(from: clientId, data: payload)
        
        messages.append(post)
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            do {
                let encryptedData = try ourEncryptionManager?.encryptToAddress(payload,
                                                                               name: clientId,
                                                                               deviceId: recipientDeviceId)
                Backend.shared.send(encryptedData!.data,
                                    from: myAccount.username,
                                    to: clientId) { (result, error) in
                    print("Send message: \(result)")
                }
            } catch {
                print("Send message error: \(error)")
            }
        }
        
        
    }
}
