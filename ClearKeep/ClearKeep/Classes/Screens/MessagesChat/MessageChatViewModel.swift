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
    var otherEncryptionManager: CKAccountSignalEncryptionManager?
    @Published var messages: [MessageModel] = []
    
    init(clientId: String) {
        self.clientId = clientId
        if let connectionDb = CKDatabaseManager.shared.database?.newConnection() {
            otherEncryptionManager = try! CKAccountSignalEncryptionManager(accountKey: clientId,
                                                                           databaseConnection: connectionDb)
        }
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
            if let ourEncryptionMng = CKSignalCoordinate.shared.ourEncryptionManager,
               let otherEncryptionMng = self.otherEncryptionManager {
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
            do {
                let signedPreKey = try SignalSignedPreKey.init(serializedData: recipientStore.signedPreKey)
                let preKey = try SignalPreKey.init(serializedData: recipientStore.preKey)
                
                let ckSignedPreKey = try CKSignedPreKey(signedPreKey: signedPreKey)
                let ckPreKeys = CKPreKey.preKeysFromSignal([preKey])
                
                let bundle = CKBundle(deviceId: UInt32(recipientStore.deviceID),
                                      registrationId: UInt32(recipientStore.registrationID),
                                          identityKey: recipientStore.identityKeyPublic,
                                          signedPreKey: ckSignedPreKey,
                                          preKeys: ckPreKeys)
                
                try self?.ourEncryptionManager?.consumeIncomingBundle(recipientStore.clientID, bundle: bundle)
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
