//
//  MessageModel.swift
//  ClearKeep
//
//  Created by Luan Nguyen on 10/30/20.
//

import Foundation

struct MessageModel: Identifiable {
    
    var id: String = String()

    var groupID: String = String()

    var groupType: String = String()

    var fromClientID: String = String()

    var clientID: String = String()

    var message = Data()

    var createdAt: Int64 = 0

    var updatedAt: Int64 = 0
}

protocol MessageChats: ObservableObject{
    
    var all: [MessageModel] { get }

    var allPublished: Published<[MessageModel]> { get }

    var allPublisher: Published<[MessageModel]>.Publisher { get }

    func add(message: MessageModel)

    func update(message: MessageModel)

    func remove(messageRemove: MessageModel)
    
    func allMessageInGroup(groupId: String) -> [MessageModel]
    
}
