
import Foundation

class SignalKitHelper {
    
    static let shared: SignalKitHelper = SignalKitHelper()
    
    
//    enum <#name#> {
//        case <#case#>
//    }
    
    
//    struct KeySend {
//
//        var myBundleStore: CKBundleStore
//
//        var remote: Signalc_SignalKeysUserResponse
//
//        var message: Data
//    }
    
    struct KeySet {
        
        var bundleStore: CKBundleStore
        
        var remote: Signalc_SignalKeysUserResponse
        
        var message: Data
    }
    
    
    private var keys = [String: KeySet]()
    
    var myBundleStore: CKBundleStore?
    
    var remote: Signalc_SignalKeysUserResponse?
    
    var sessionPreKeyBundle: SessionPreKeyBundle?

    
}

extension SignalKitHelper {
    

}

extension SignalKitHelper {
    
    func encrypt(_ data: Data) throws -> Signalc_PublishRequest {
        
//        self.myBundleStore = keySend.myBundleStore
//        self.remote = keySend.remote
//
//        let remoteAddress = SignalAddress(identifier: keySend.remote.clientID,
//                                          deviceId: UInt32(keySend.remote.deviceID))
//
//        let mySessionBuilder = SessionBuilder(remoteAddress: remoteAddress, store: keySend.myBundleStore)
//
////        var sessionPreKeyBundle: SessionPreKeyBundle?
//
//        do {
//            sessionPreKeyBundle = try SessionPreKeyBundle(preKey: keySend.remote.preKey,
//                                                          signedPreKey: keySend.remote.signedPreKey,
//                                                          identityKey: keySend.remote.identityKeyPublic)
//
//            try mySessionBuilder.process(preKeyBundle: sessionPreKeyBundle!)
//
//            let mySessionCipher = SessionCipher(store: keySend.myBundleStore, remoteAddress: remoteAddress)
//
//            let messageEncrypt: CipherTextMessage = try mySessionCipher.encrypt(keySend.message)
//
//            let request: Signalc_PublishRequest = .with {
//                $0.receiveID = remoteAddress.identifier
//                $0.senderID = keySend.myBundleStore.address.identifier
//                $0.message = messageEncrypt.data
//            }
//
//            print(request.receiveID)
//
//            return request
//
//        } catch {
//            print(error.localizedDescription)
//        }
        
        
        return try Signalc_PublishRequest(serializedData: Data())
    }

}

extension SignalKitHelper {
    
    func decrypt(_ sealedMessage: Signalc_Publication) throws -> Data? {
        
        guard let myBundleStore = self.myBundleStore, let userRemote = remote else {
            return nil
        }
        
        
        let remoteAddress = SignalAddress(identifier: userRemote.clientID,
                                          deviceId: UInt32(userRemote.deviceID))
        
        let mySessionBuilder = SessionBuilder(remoteAddress: remoteAddress, store: myBundleStore)
        
        do {

            try mySessionBuilder.process(preKeyBundle: sessionPreKeyBundle!)
            
            let mySessionCipher = SessionCipher(store: myBundleStore, remoteAddress: remoteAddress)
            
            let incomingMessage: PreKeySignalMessage = try PreKeySignalMessage(from: sealedMessage.message)
            
            
            
            
            guard let keyData = try myBundleStore.identityKeyStore.identity(for: SignalAddress(identifier: "bob", deviceId: 123)),
                  let privateKey = try? PrivateKey(unverifiedPoint: keyData),
                  let keyPair = try? KeyPair(privateKey: privateKey) else {
                return nil
            }

            let trust = try myBundleStore.identityKeyStore.isTrusted(identity: keyData, for: SignalAddress(identifier: "bob", deviceId: 123))
            
            
            let bobPreKeyRecord = SessionPreKey(id: sessionPreKeyBundle!.preKeyId, keyPair: keyPair)

            try self.myBundleStore?.preKeyStore.store(preKey: bobPreKeyRecord)
            
            guard let bobSignedPreKeySignature =
                try? keyPair.privateKey.sign(
                    message: remote!.identityKeyPublic) else {
                return nil
            }

            let bobSignedPreKeyRecord = SessionSignedPreKey(id: sessionPreKeyBundle!.preKeyId,
                                                            timestamp: UInt64(Date().timeIntervalSince1970),
                                                            keyPair: keyPair,
                                                            signature: bobSignedPreKeySignature)
            
            
            try myBundleStore.signedPreKeyStore.store(signedPreKey: bobSignedPreKeyRecord)
            
            
            
            
            let plaintext = try mySessionCipher.decrypt(preKeySignalMessage: incomingMessage)
            
            return plaintext
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
