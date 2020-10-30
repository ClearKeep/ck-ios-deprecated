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
    var otherEncryptionManager: CKAccountSignalEncryptionManager?
    var ourEncryptionManager: CKAccountSignalEncryptionManager?
    @Published var messages: [MessageModel] = []
    
    init(clientId: String) {
        self.clientId = clientId
        if let connectionDb = CKDatabaseManager.shared.database?.newConnection() {
            otherEncryptionManager = try! CKAccountSignalEncryptionManager(accountKey: clientId,
                                                                           databaseConnection: connectionDb)
        }
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
            if let ourEncryptionMng = self.ourEncryptionManager, let otherEncryptionMng = self.otherEncryptionManager {
                do {
                    let decryptedData = try ourEncryptionMng.decryptFromAddress(publication.message,
                                                                                     name: clientId,
                                                                                     deviceId: otherEncryptionMng.registrationId)
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
//            let signedPreKey = CKSignedPreKey(signedPreKey: recipientStore.signedPreKey)
            let signedPreKey = CKSignedPreKey(withPreKeyId: UInt32(recipientStore.preKeyID),
                                              publicKey: recipientStore.signedPreKey,
                                              signature: recipientStore.signedPreKeySignature)
            let preKey = CKPreKey(withPreKeyId: UInt32(recipientStore.preKeyID), publicKey: recipientStore.identityKeyPublic)
            
            let otherBundle = CKBundle(deviceId: UInt32(recipientStore.deviceID),
                                       identityKey: recipientStore.identityKeyPublic,
                                       signedPreKey: signedPreKey,
                                       preKeys: [preKey])
            do {
                try self?.otherEncryptionManager?.consumeIncomingBundle(recipientStore.clientID, bundle: otherBundle)
            } catch {
                print("consumeIncomingBundle Error: \(error)")
            }
            
            Backend.shared.authenticator.recipientID = recipientStore.clientID
            Backend.shared.authenticator.recipientStore = recipientStore
        }
    }
    
    func send(messageStr: String) {
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        let post = MessageModel(from: clientId, data: payload)
        
        messages.append(post)
        Backend.shared.send(messageStr, to: clientId) { (result, error) in
            print("Send message: \(result)")
        }
    }
}
