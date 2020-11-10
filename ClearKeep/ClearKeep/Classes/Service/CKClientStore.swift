
import Foundation
import SignalProtocolObjC

class CKClientStore {
    
    enum CKClientError: LocalizedError {
        case encoding(message: String)
        
        case encrypt(message: String)
        case decrypt(message: String)
        
        case initKeyPair(message: String)
    }
    
    
    var keyHelper: SignalKeyHelper!
    
    var localRegistrationId: Int32! = 0
    
    var inMemoryStore: SignalStoreInMemoryStorage = SignalStoreInMemoryStorage()
    
    var identityKeyPair: SignalIdentityKeyPair!
    
    var preKey1: SignalPreKey!
    
    var signedPreKey: SignalSignedPreKey!
    
    let address: SignalAddress
    
    var preKeyBundle: SignalPreKeyBundle!
    
    var context: SignalContext!
    
    
    init(clientID: String, deviceID: Int32) {
        
        self.address = SignalAddress(name: clientID, deviceId: deviceID)
        
        let storage = SignalStorage.init(signalStore: inMemoryStore)
        
        context = SignalContext(storage: storage)
        
        keyHelper = SignalKeyHelper(context: context!)!
        
        identityKeyPair = keyHelper.generateIdentityKeyPair()
        
        localRegistrationId = Int32(keyHelper.generateRegistrationId())
        
        inMemoryStore.identityKeyPair = identityKeyPair
        inMemoryStore.localRegistrationId = UInt32(localRegistrationId)
        
        let preKeys = keyHelper.generatePreKeys(withStartingPreKeyId: 0, count: 2)
        
        preKey1 = preKeys.first!
        
        
        signedPreKey = keyHelper.generateSignedPreKey(withIdentity: identityKeyPair!, signedPreKeyId: 1)
        
        inMemoryStore.storePreKey(preKey1.serializedData()!, preKeyId: preKey1.preKeyId)
        
        inMemoryStore.storeSignedPreKey(signedPreKey!.serializedData()!, signedPreKeyId: signedPreKey!.preKeyId)
        
    }
}

// MARK: Encrypt + decrypt message
extension CKClientStore {
    
    /// Encrypt message
    /// - Parameters:
    ///   - remoteAddress: remoteAddress description
    ///   - recipientStore: recipientStore description
    ///   - message: message
    /// - Throws: Error
    /// - Returns: SignalCiphertext
//    func encrypt(remoteAddress: SignalAddress,
//                 recipientStore: Signalc_SignalKeysUserResponse,
//                 message: String) throws -> SignalCiphertext {
//        
//        do {
//            let remotePrekey = try SignalPreKey.init(serializedData: recipientStore.preKey)
//            let remoteSignedPrekey = try SignalPreKey.init(serializedData: recipientStore.signedPreKey)
//            
//            guard let preKeyKeyPair = remotePrekey.keyPair, let signedPrekeyKeyPair = remoteSignedPrekey.keyPair else {
//                throw CKClientError.initKeyPair(message: "Init KeyPair error")
//            }
//            
//            let signalPreKeyBundle = try SignalPreKeyBundle(registrationId: UInt32(recipientStore.registrationID),
//                                                            deviceId: UInt32(recipientStore.deviceID),
//                                                            preKeyId: UInt32(recipientStore.preKeyID),
//                                                            preKeyPublic: preKeyKeyPair.publicKey,
//                                                            signedPreKeyId: UInt32(recipientStore.signedPreKeyID),
//                                                            signedPreKeyPublic: signedPrekeyKeyPair.publicKey,
//                                                            signature: recipientStore.signedPreKeySignature,
//                                                            identityKey: recipientStore.identityKeyPublic)
//            
//            
//            let remoteSessionBuilder = SignalSessionBuilder(address: remoteAddress, context: context)
//            
//            try remoteSessionBuilder.processPreKeyBundle(signalPreKeyBundle)
//            
//            let remoteSessionCipher = SignalSessionCipher(address: remoteAddress, context: context)
//            
//            guard let messageUTF8 = message.data(using: .utf8) else {
//                throw CKClientError.encoding(message: "Encoding message utf8 fail")
//            }
//            
//            let cipherText = try remoteSessionCipher.encryptData(messageUTF8)
//            
//            return cipherText
//            
//        } catch {
//            
//            throw CKClientError.encrypt(message: "Encrypt message error --> \(error.localizedDescription)")
//        }
//    }
    
    
    /// Decrypt message
    /// - Parameters:
    ///   - remoteAddress: address
    ///   - cipherData: cipher data
    /// - Throws: error 
    /// - Returns:
    func decrypt(remoteAddress: SignalAddress, cipherData: Data) throws -> Data {
        
        let sessionCipher = SignalSessionCipher(address: remoteAddress, context: context)
        
        let cipherText = SignalCiphertext(data: cipherData, type: .preKeyMessage)
        
        do {
            
            let messageData = try sessionCipher.decryptCiphertext(cipherText)
            
            return messageData
            
        } catch {
            throw CKClientError.decrypt(message: "Decrypt message error --> \(error.localizedDescription)")
        }
        
    }
    
}
