//
//  User.swift
//  ClearKeep
//
//  Created by Seoul on 11/13/20.
//

import Foundation

struct User: Codable {
    var id: String
    var token: String
    var hash: String
    var displayName: String
    var email: String
    var workspace_domain: WorkspaceDomain
}

struct WorkspaceDomain: Codable {
    var workspace_domain: String
    var workspace_name: String
    
    static let `default` = WorkspaceDomain(workspace_domain: "54.235.68.160:25000", workspace_name: "Development Server")

    var grpc: String {
        get {
            let arr = workspace_domain.components(separatedBy: ":")
            let host: String = arr.first ?? ""
            return host
        }
    }
    
    var grpc_port: Int {
        get {
            let arr = workspace_domain.components(separatedBy: ":")
            let port = Int(arr.last ?? "") ?? 0
            return port
        }
    }

}
