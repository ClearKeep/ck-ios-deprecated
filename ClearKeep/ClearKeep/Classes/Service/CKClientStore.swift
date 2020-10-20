
import Foundation
import SignalProtocolObjC

class CKClientStore {
    
    var clientID: String
    
    var deviceID: Int32
    
    
//    var signalPreKey: SignalPreKeyBundle = SignalPreKeyBundle()
//
//    var identityKey: Data = Data()
//
//    var preKey: SignalPreKey = SignalPreKey()
    
    var identityKeyStore: SignalIdentityKeyPair = SignalIdentityKeyPair()
    
    var preKeyStore: SignalPreKey = SignalPreKey()
    
    var signedPreKeyStore: SignalPreKeyStore!
    
    var signalPrekeyBundle: SignalPreKeyBundle = SignalPreKeyBundle()
    
    var sessionStore: SignalSessionStore!
    
    
    
    init(clientID: String, deviceID: Int32) {
        self.clientID = clientID
        self.deviceID = deviceID
    
        
        let context = SignalKeyHelper.init().generateIdentityKeyPair()
        
        

        
        
//        signalKey.generatePreKeys(withStartingPreKeyId: 1, count: 1)

//        signalKey.generateSignedPreKey(withIdentity: keyPair!, signedPreKeyId: 1)
        
        
    }
    
}
