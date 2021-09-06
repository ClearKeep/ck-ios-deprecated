//
//  UserDefaultsUsers.swift
//  ClearKeep
//
//  Created by Diflega on 8/27/21.
//

import Foundation

class UserDefaultsUsers {
    
    private lazy var defaults: UserDefaults = {
        return UserDefaults.standard
    }()
    
    var users: [User] {
        do {
            let users = try defaults.getObject(forKey: Constants.keySaveUsers, castTo: [User].self)
            return users
        } catch {
            return []
        }
    }
    
    func saveUsers(users: [User]) {
        do {
            try defaults.setObject(users, forKey: Constants.keySaveUsers)
        } catch {
            
        }
    }
    
    func deleteUser() {
        
    }
    
    var refreshTokens: [String] {
        guard let refreshTokens = defaults.array(forKey: Constants.keySaveRefreshTokens) as? [String] else { return [] }
        return refreshTokens
    }
    
    func saveRefreshTokens(refreshTokens: [String]) {
        defaults.setValue(refreshTokens, forKey: Constants.keySaveRefreshTokens)
        defaults.synchronize()
    }

}
