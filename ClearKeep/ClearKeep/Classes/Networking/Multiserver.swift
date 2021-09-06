//
//  Multiserver.swift
//  ClearKeep
//
//  Created by Diflega on 8/24/21.
//

import Foundation

class Multiserver {
    static let instance = Multiserver()
    
    lazy var servers = getJoindServers()
    lazy var domains = getDomains()
    
    lazy var currentIndex: Int = getCurrentIndex()
    var currentServer: Backend {
        get {
            return servers[currentIndex]
        }
    }
    
    // MARK: - Method
    fileprivate func getJoindServers() -> [Backend] {
        var servers = [Backend]()
        let domains = getDomains()
        domains.forEach { servers.append(Backend(workspace_domain: $0)) }
        return servers
    }
    
    func getDomains() -> [WorkspaceDomain] {
        do {
            let users = try UserDefaults.standard.getObject(forKey: Constants.keySaveUsers, castTo: [User].self)
            let domains = users.compactMap { return $0.workspace_domain }
            return domains
        } catch {
            return [WorkspaceDomain.default]
        }
    }
    
    func getCurrentIndex() -> Int {
        do {
            let userLogin = try UserDefaults.standard.getObject(forKey: Constants.keySaveUser, castTo: User.self)
            let users = try UserDefaults.standard.getObject(forKey: Constants.keySaveUsers, castTo: [User].self)

            if let index = users.firstIndex(where: { user in
                return user.id == userLogin.id
            }) {
                return index
            }
            
            return 0
        } catch {
            return 0
        }

    }
    
    func listenServers() {
        let users = UserDefaultsUsers().users

        for (index, server) in servers.enumerated() {
            server.signalSubscrible(clientId: users[index].id)
            server.notificationSubscrible(clientId: users[index].id)
        }
    }
    
    func unListenServers() {
        let users = UserDefaultsUsers().users

        for (index, server) in servers.enumerated() {
            server.notificationUnSubscrible(clientId: users[index].id)
            server.signalUnsubcrible(clientId: users[index].id)
        }
    }
}
