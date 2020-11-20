//
//  Group.swift
//  ClearKeep
//
//  Created by Seoul on 11/19/20.
//

import Foundation

struct GroupModel: Identifiable {
    var id: String
    var groupID: String
    var groupName: String
    var groupAvatar: String
    var groupType: String
    var createdByClientID: String
    var createdAt: Int64
    var updatedByClientID: String
    var lstClientID: [String]
    var updatedAt: Int64
    
}
