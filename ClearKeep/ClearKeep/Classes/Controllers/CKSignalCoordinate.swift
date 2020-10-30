//
//  CKSignalCoordinate.swift
//  ClearKeep
//
//  Created by VietAnh on 10/30/20.
//

import Foundation

class CKSignalCoordinate {
    static let shared = CKSignalCoordinate()
    
    var ourEncryptionManager: CKAccountSignalEncryptionManager?
    var othersEncryptionManager: [String: CKAccountSignalEncryptionManager] = [:]
    
    func getOtherEncryptionManager(byClientId clientId: String) -> CKAccountSignalEncryptionManager? {
        return othersEncryptionManager[clientId]
    }
}
