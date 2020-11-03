//
//  CKPreKey.swift
//  ClearKeep
//
//  Created by VietAnh on 10/29/20.
//

import Foundation

class CKPreKey {
    let preKeyId: UInt32
    let publicKey: Data
    
    init(withPreKeyId preKeyId: UInt32, publicKey: Data) {
        self.preKeyId = preKeyId
        self.publicKey = publicKey
    }
}

extension CKPreKey {
    static func preKeysFromSignal(_ preKeys: [SignalPreKey]) -> [CKPreKey] {
        var omemoPreKeys: [CKPreKey] = []
        preKeys.forEach { (signalPreKey) in
            guard let pk = signalPreKey.keyPair?.publicKey else { return }
            let omemoPreKey = CKPreKey(withPreKeyId: signalPreKey.preKeyId, publicKey: pk)
            omemoPreKeys.append(omemoPreKey)
        }
        return omemoPreKeys
    }
}
