//
//  RealmManager.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/19/21.
//

import Foundation

class RealmManager {
    
    // MARK: - Singleton
    static let shared = RealmManager()
    private(set) var realmGroups: RealmGroups
    private(set) var realmMessages: RealmMessages
    
    // MARK: - Init
    private init() {
        realmGroups = RealmGroups()
        realmMessages = RealmMessages()
    }
}
