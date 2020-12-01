//
//  HistoryChatViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/19/20.
//

import SwiftUI

class HistoryChatViewModel: ObservableObject, Identifiable{
    
    var groupRealm = RealmGroups()
    
    func getJoinedGroup(){
        
        Backend.shared.getJoinnedGroup { (result, error) in
            if let result = result {
                result.lstGroup.forEach { (groupResponse) in
                    
                    let lstClientID = groupResponse.lstClient.map{$0.id}
                    
                    
                    let groupModel = GroupModel(groupID: groupResponse.groupID,
                                                groupName: groupResponse.groupName,
                                                groupAvatar: groupResponse.groupAvatar,
                                                groupType: groupResponse.groupType,
                                                createdByClientID: groupResponse.createdByClientID,
                                                createdAt: groupResponse.createdAt,
                                                updatedByClientID: groupResponse.updatedByClientID,
                                                lstClientID: lstClientID,
                                                updatedAt: groupResponse.updatedAt,
                                                lastMessageAt: groupResponse.lastMessageAt,
                                                lastMessage: groupResponse.lastMessage.message)
                    
                    if self.groupRealm.isExistGroup(findGroup: groupModel) {
                        DispatchQueue.main.async {
                            self.groupRealm.update(group: groupModel)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.groupRealm.add(group: groupModel)
                        }
                    }
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
