//
//  Group.swift
//  ClearKeep
//
//  Created by Seoul on 11/19/20.
//

import Foundation
import RealmSwift

struct GroupModel: Identifiable , Codable {
    var id : String = UUID().uuidString
    var groupID: String
    var groupName: String
    var groupAvatar: String
    var groupType: String
    var createdByClientID: String
    var createdAt: Int64
    var updatedByClientID: String
    var lstClientID = Array<String>()
    var updatedAt: Int64
    var lastMessageAt: Int64 = 0
    var lastMessage = Data()
}

protocol GroupChats: ObservableObject{
    var all: [GroupModel] { get }

    var allPublished: Published<[GroupModel]> { get }

    var allPublisher: Published<[GroupModel]>.Publisher { get }

    func add(group: GroupModel)

    func update(group: GroupModel)

    func remove(groupRemove: GroupModel)
    
    func isExistGroup(findGroup: GroupModel) -> Bool
}

extension GroupModel: Equatable {

    static func ==(lhs: GroupModel, rhs: GroupModel) -> Bool {
        lhs.groupID == rhs.groupID
    }
}
