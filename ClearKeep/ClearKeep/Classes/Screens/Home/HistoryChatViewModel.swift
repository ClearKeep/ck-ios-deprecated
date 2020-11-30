//
//  HistoryChatViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/19/20.
//

import SwiftUI

class HistoryChatViewModel: ObservableObject, Identifiable{
    
    @Published var groups : [GroupModel] = []
    
    func getJoinedGroup(){
        Backend.shared.getJoinnedGroup { (result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    self.groups.removeAll()
                    result.lstGroup.forEach { (group) in
                        let message = group.lastMessage
                        let lastMess = MessageGroup()
                        lastMess.id = message.id
                        lastMess.groupID = message.groupID
                        lastMess.clientID = message.clientID
                        lastMess.fromClientID = message.fromClientID
                        lastMess.createdAt = message.createdAt
                        lastMess.message = message.message
                        lastMess.updatedAt = message.updatedAt
                        lastMess.groupType = message.groupType
                        
//                        let groupChat = GroupChat()
//                        groupChat.groupId = group.groupID
//                        groupChat.groupName = group.groupName
//                        groupChat.avatarGroup = group.groupAvatar
//                        groupChat.groupType = group.groupType
//                        groupChat.lstClientID = group.lstClientID
//                        groupChat.lastMessage = lastMess
//                        groupChat.lastMessageAt = group.lastMessageAt
//                        groupChat.createdByClientID = group.createdByClientID
//                        groupChat.createdAt = group.createdAt
//                        groupChat.updatedByClientID = group.updatedByClientID
//                        groupChat.updatedAt = group.updatedAt
                        
//                        self.groups2.append(groupChat)
//                        self.groups.append(GroupModel(id: "", groupID: group.groupID, groupName: group.groupName, groupAvatar: group.groupAvatar, groupType: group.groupType, createdByClientID: group.createdByClientID, createdAt: group.createdAt, updatedByClientID: group.updatedByClientID, lstClientID: group.lstClientID, updatedAt: group.updatedAt))
                    }
//                    CKExtensions.saveAllGroup(allGroup: self.groups)
                }
            }
        }
    }
    
    func getGroupName(group: GroupModel) -> String{
        var userNameLogin = UserDefaults.standard.string(forKey: Constants.keySaveUserNameLogin) ?? ""
        userNameLogin = group.groupName.replacingOccurrences(of: userNameLogin, with: "")
        userNameLogin = userNameLogin.replacingOccurrences(of: "-", with: "")
        return group.groupType == "peer" ? userNameLogin : group.groupName
    }
    
    func getClientIdFriend(listClientID: [String]) -> String {
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            let idFriend = listClientID.filter {$0 != myAccount.username}
            return idFriend.isEmpty ? "" : idFriend[0]
        }
        return ""
    }
}
