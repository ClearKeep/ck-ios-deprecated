//
//  CKBundle.swift
//  ClearKeep
//
//  Created by VietAnh on 10/29/20.
//

import Foundation

public enum CKBundleError: Error {
    case unknown
    case notFound
    case invalid
    case keyGeneration
}

class CKBundle: NSObject {
    let deviceId: UInt32
    let identityKey: Data
    let signedPreKey: CKSignedPreKey
    let preKeys: [CKPreKey]
    
    init(deviceId: UInt32, identityKey: Data, signedPreKey: CKSignedPreKey, preKeys: [CKPreKey]) {
        self.deviceId = deviceId
        self.identityKey = identityKey
        self.signedPreKey = signedPreKey
        self.preKeys = preKeys
    }
}

extension CKBundle {
    
    /// Returns copy of bundle with new preKeys
    func copyBundle(newPreKeys: [CKPreKey]) -> CKBundle {
        let bundle = CKBundle(deviceId: deviceId, identityKey: identityKey, signedPreKey: signedPreKey, preKeys: newPreKeys)
        return bundle
    }
    
    /// Returns Signal bundle from a random PreKey
    func signalBundle() throws -> SignalPreKeyBundle {
        let index = Int(arc4random_uniform(UInt32(preKeys.count)))
        let preKey = preKeys[index]
        let preKeyBundle = try SignalPreKeyBundle(registrationId: 0,
                                                  deviceId: deviceId,
                                                  preKeyId: preKey.preKeyId,
                                                  preKeyPublic: preKey.publicKey,
                                                  signedPreKeyId: signedPreKey.preKeyId,
                                                  signedPreKeyPublic: signedPreKey.publicKey,
                                                  signature: signedPreKey.signature, identityKey: identityKey)
        return preKeyBundle
    }
    
    convenience init(deviceId: UInt32, identity: SignalIdentityKeyPair, signedPreKey: SignalSignedPreKey, preKeys: [SignalPreKey]) throws {

        let omemoSignedPreKey = try CKSignedPreKey(signedPreKey: signedPreKey)
        let omemoPreKeys = CKPreKey.preKeysFromSignal(preKeys)
        
        // Double check that this bundle is valid
        if let preKey = preKeys.first,
            let preKeyPublic = preKey.keyPair?.publicKey {
            let _ = try SignalPreKeyBundle(registrationId: 0, deviceId: deviceId, preKeyId: preKey.preKeyId, preKeyPublic: preKeyPublic, signedPreKeyId: omemoSignedPreKey.preKeyId, signedPreKeyPublic: omemoSignedPreKey.publicKey, signature: omemoSignedPreKey.signature, identityKey: identity.publicKey)
        } else {
            throw CKBundleError.invalid
        }
        
        self.init(deviceId: deviceId, identityKey: identity.publicKey, signedPreKey: omemoSignedPreKey, preKeys: omemoPreKeys)
    }
    
    convenience init(identity: CKAccountSignalIdentity, signedPreKey: CKSignalSignedPreKey, preKeys: [CKSignalPreKey]) throws {
        let omemoSignedPreKey = try CKSignedPreKey(signedPreKey: signedPreKey)
        
        var omemoPreKeys: [CKPreKey] = []
        preKeys.forEach { (preKey) in
            guard let keyData = preKey.keyData, keyData.count > 0 else { return }
            do {
                let signalPreKey = try SignalPreKey(serializedData: keyData)
                guard let pk = signalPreKey.keyPair?.publicKey else { return }
                let omemoPreKey = CKPreKey(withPreKeyId: preKey.keyId, publicKey: pk)
                omemoPreKeys.append(omemoPreKey)
            } catch let error {
                NSLog("Found invalid prekey: \(error)")
            }
        }
        
        // Double check that this bundle is valid
        if let preKey = preKeys.first, let preKeyData = preKey.keyData,
            let signalPreKey = try? SignalPreKey(serializedData: preKeyData),
            let preKeyPublic = signalPreKey.keyPair?.publicKey {
            let _ = try SignalPreKeyBundle(registrationId: 0, deviceId: identity.registrationId, preKeyId: preKey.keyId, preKeyPublic: preKeyPublic, signedPreKeyId: omemoSignedPreKey.preKeyId, signedPreKeyPublic: omemoSignedPreKey.publicKey, signature: omemoSignedPreKey.signature, identityKey: identity.identityKeyPair.publicKey)
        } else {
            throw CKBundleError.invalid
        }
        
        self.init(deviceId: identity.registrationId, identityKey: identity.identityKeyPair.publicKey, signedPreKey: omemoSignedPreKey, preKeys: omemoPreKeys)
    }
}
