
import Foundation
import SignalProtocol

class CKIdentityKeyStore: IdentityKeyStore {
    
    /// The type that distinguishes different devices/users
    typealias Address = SignalAddress
    
    
    required init(with keyPair: Data) {
        self.identityKey = keyPair
    }
    
    /// The local identity key data
    private var identityKey: Data!

    /// Dictionary of the identities
    private var identities = [SignalAddress : Data]()

    
    init() { }
    
    
}

// MARK: Store
extension CKIdentityKeyStore {

    /**
     Save the identity key pair.
     - parameter identityKeyData: The data to store
     - throws: `SignalError` of type `storageError`, if the data could not be saved
     */
    func store(identityKeyData: Data) {
        identityKey = identityKeyData
    }
    
    
    /**
     Store a remote client's identity key as trusted.
     - parameter identity: The identity key data (may be nil, if the key should be removed)
     - parameter address: The address of the remote client
     */
    func store(identity: Data?, for address: SignalAddress) throws {
        identities[address] = identity
    }

}


// MARK: Identity Key
extension CKIdentityKeyStore {
    
    /**
     Return the identity key pair.
     - returns: The identity key pair data
     */
    func getIdentityKeyData() throws -> Data {
        if identityKey == nil {
            identityKey = try SignalCrypto.generateIdentityKeyPair()
        }
        return identityKey
    }

    /**
     Return the identity for the given address, if there is any.
     - parameter address: The address of the remote client
     - returns: The identity for the address, or nil if no data exists
     */
    func identity(for address: SignalAddress) throws -> Data? {
        return identities[address]
    }

}
