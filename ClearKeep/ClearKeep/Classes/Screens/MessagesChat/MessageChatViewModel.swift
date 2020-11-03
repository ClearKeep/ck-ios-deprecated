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
    @Published var messages: [MessageModel] = []
    
    init(clientId: String) {
        self.clientId = clientId
//        if let connectionDb = CKDatabaseManager.shared.database?.newConnection() {
//            otherEncryptionManager = try! CKAccountSignalEncryptionManager(accountKey: clientId,
//                                                                           databaseConnection: connectionDb)
//        }
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
        requestBundleRecipient(byClientId: clientId)
//        Backend.shared.heard = { (clientId, publication) in
//
//        }
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
//            if let ourEncryptionMng = CKSignalCoordinate.shared.ourEncryptionManager,
//               let otherEncryptionMng = self.otherEncryptionManager {
//                do {
//                    let decryptedData = try ourEncryptionMng.decryptFromAddress(publication.message,
//                                                                                     name: clientId,
//                                                                                     deviceId: otherEncryptionMng.registrationId)
//                    let messageDecryption = String(data: decryptedData, encoding: .utf8)
//                    print("Message decryption: \(messageDecryption ?? "Empty error")")
//
//                } catch {
//                    print("Decryption message error: \(error)")
//                }
//            }
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
//                let remotePrekey = try SignalPreKey.init(serializedData: recipientStore.preKey)
//                let remoteSignedPrekey = try SignalPreKey.init(serializedData: recipientStore.signedPreKey)
//                
//                guard let preKeyKeyPair = remotePrekey.keyPair, let signedPrekeyKeyPair = remoteSignedPrekey.keyPair else {
//                    return
//                }
//                
//                let signalPreKeyBundle = try SignalPreKeyBundle(registrationId: UInt32(recipientStore.registrationID),
//                                                                deviceId: UInt32(recipientStore.deviceID),
//                                                                preKeyId: UInt32(recipientStore.preKeyID),
//                                                                preKeyPublic: preKeyKeyPair.publicKey,
//                                                                signedPreKeyId: UInt32(recipientStore.signedPreKeyID),
//                                                                signedPreKeyPublic: signedPrekeyKeyPair.publicKey,
//                                                                signature: recipientStore.signedPreKeySignature,
//                                                                identityKey: recipientStore.identityKeyPublic)
//                
//                
//                let remoteAddress = SignalAddress(name: recipientStore.clientID, deviceId: recipientStore.deviceID)
//                let remoteSessionBuilder = SignalSessionBuilder(address: remoteAddress, context: Backend.shared.authenticator.clientStore.context)
//                
//                try remoteSessionBuilder.processPreKeyBundle(signalPreKeyBundle)
                
                
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

                try self?.ourEncryptionManager?.consumeIncomingBundle(recipientStore.clientID, bundle: bundle)
                
                
//                let signalPreKeyBundle = try SignalPreKeyBundle(registrationId: UInt32(recipientStore.registrationID),
//                                                                deviceId: UInt32(recipientStore.deviceID),
//                                                                preKeyId: UInt32(recipientStore.preKeyID),
//                                                                preKeyPublic: recipientStore.preKey,
//                                                                signedPreKeyId: UInt32(recipientStore.signedPreKeyID),
//                                                                signedPreKeyPublic: recipientStore.signedPreKey,
//                                                                signature: recipientStore.signedPreKeySignature,
//                                                                identityKey: recipientStore.identityKeyPublic)
//
//
//                let remoteAddress = SignalAddress(name: recipientStore.clientID, deviceId: recipientStore.deviceID)
//                let remoteSessionBuilder = SignalSessionBuilder(address: remoteAddress, context: self!.otherEncryptionManager!.signalContext)
//
//                try remoteSessionBuilder.processPreKeyBundle(signalPreKeyBundle)
//
//                let remoteSessionCipher = SignalSessionCipher(address: remoteAddress, context: self!.ourEncryptionManager!.signalContext)
//
//                guard let messageUTF8 = "message".data(using: .utf8) else {
//                    return
//                }
//
//                let cipherText = try remoteSessionCipher.encryptData(messageUTF8)
                print("")
            } catch {
                print("consumeIncomingBundle Error: \(error)")
            }
        }
    }
    
    func send(messageStr: String) {
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        let post = MessageModel(from: clientId, data: payload)
        
        messages.append(post)
        if let ourUsername = CKSignalCoordinate.shared.ourEncryptionManager?.storage.accountKey {
            do {
                let encryptedData = try ourEncryptionManager?.encryptToAddress(payload, name: ourUsername, deviceId: 1)
                Backend.shared.send(encryptedData!.data, from: ourUsername, to: clientId) { (result, error) in
                    print("Send message: \(result)")
                }
            } catch {
                print("Send message error: \(error)")
            }
        }
        
        
    }
}
