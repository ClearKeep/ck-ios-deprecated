//
//  MessageModel.swift
//  ClearKeep
//
//  Created by Luan Nguyen on 10/30/20.
//

import Foundation

struct MessageModel: Identifiable {
    
    var id: String = String()

    var groupID: Int64 = 0

    var groupType: String = String()

    var fromClientID: String = String()

    var clientID: String = String()

    var message = Data()

    var createdAt: Int64 = 0

    var updatedAt: Int64 = 0
    
    var myMsg: Bool = true
    
    var photo: Data?
    
    var clientWorkspaceDomain: String
    
    init(id: String,
         groupID: Int64,
         groupType: String,
         fromClientID: String,
         clientID: String,
         message: Data,
         createdAt: Int64,
         updatedAt: Int64,
         clientWorkspaceDomain: String) {
        self.id = id
        self.groupID = groupID
        self.groupType = groupType
        self.fromClientID = fromClientID
        self.clientID = clientID
        self.message = message
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            myMsg = myAccount.username == fromClientID
        }
        self.clientWorkspaceDomain = clientWorkspaceDomain
    }
}

protocol MessageChats: ObservableObject{
    
    var all: [MessageModel] { get }

    var allPublished: Published<[MessageModel]> { get }

    var allPublisher: Published<[MessageModel]>.Publisher { get }

    func add(message: MessageModel)

    func update(message: MessageModel)

    func remove(messageRemove: MessageModel)
    
    func allMessageInGroup(groupId: Int64) -> [MessageModel]
    
}

struct SectionWithMessage {
    var title: String = String()
    var messages: [MessageModel] = []
}

struct MessageDisplayInfo {    
    var message : MessageModel
    var rectCorner: UIRectCorner
    var showAvatarAndUserName: Bool
}
