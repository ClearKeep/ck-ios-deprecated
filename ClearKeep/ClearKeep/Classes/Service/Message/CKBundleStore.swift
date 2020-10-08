
import Foundation
import SignalProtocol


class CKBundleStore: GroupKeyStore {
    
    
    
    // MARK: Typealiases
    
    /// The identifier to distinguish between different groups and devices/users
    typealias GroupAddress = SignalSenderKeyName
    
    /// The type implementing the sender key store
    typealias SenderKeyStoreType = CKSenderKeyStore
    
    /// The identifier to distinguish between different devices/users
    typealias Address = SignalAddress
    
    /// The type implementing the identity key store
    typealias IdentityKeyStoreType = CKIdentityKeyStore
    
    /// The type implementing the session store
    typealias SessionStoreType = CKSessionStore

    
    // MARK: Variables
    let senderKeyStore: CKSenderKeyStore = CKSenderKeyStore()
    
    let identityKeyStore: CKIdentityKeyStore
    
    let preKeyStore: PreKeyStore = CKPreKeyStore()
    
    let sessionStore: CKSessionStore = CKSessionStore()
    
    let signedPreKeyStore: SignedPreKeyStore = CKSignedPreKeyStore()
    
    
    
    
    init() {
        self.identityKeyStore = CKIdentityKeyStore()
        
    }
    
    
    init(with keyPair: Data) {
        self.identityKeyStore = CKIdentityKeyStore(with: keyPair)
    }
    
    
}
