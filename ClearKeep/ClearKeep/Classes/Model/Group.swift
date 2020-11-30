//
//  Group.swift
//  ClearKeep
//
//  Created by Seoul on 11/19/20.
//

import Foundation
import RealmSwift

struct GroupModel: Identifiable , Codable {
    var id = UUID()
    var groupID: String
    var groupName: String
    var groupAvatar: String
    var groupType: String
    var createdByClientID: String
    var createdAt: Int64
    var updatedByClientID: String
    var lstClientID = List<String>()
    var updatedAt: Int64
    
}

protocol GroupChats: ObservableObject{
    var all: [GroupModel] { get }

    var allPublished: Published<[GroupModel]> { get }

    var allPublisher: Published<[GroupModel]>.Publisher { get }

    func add(group: GroupModel)

    func update(group: GroupModel)

    func remove(groupRemove: GroupModel)
}

extension GroupModel: Equatable {

    static func ==(lhs: GroupModel, rhs: GroupModel) -> Bool {
        lhs.id == rhs.id
    }
}
