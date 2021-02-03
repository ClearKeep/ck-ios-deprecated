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
}
