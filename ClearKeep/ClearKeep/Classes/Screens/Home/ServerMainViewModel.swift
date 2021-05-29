//
//  ServerMainViewModel.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/26/21.
//

import SwiftUI


class ServerMainViewModel: ObservableObject {
    @Published var groups: [GroupModel] = []
    @Published var peers: [GroupModel] = []
    
    func reloadData() {
        DispatchQueue.main.async {
            let convertedAndSortedGroup = self.convertedAndSortedGroup(RealmManager.shared.getAllGroups())
            self.groups = convertedAndSortedGroup.groups
            self.peers = convertedAndSortedGroup.peers
        }
    }
    
    func getJoinedGroup(){
        reloadData()
        Debug.DLog("getJoinnedGroup")
        
        Backend.shared.getJoinnedGroup { [weak self] (result, error) in
            guard let self = self else { return }
            if let result = result {
                let dispatchGroup = DispatchGroup()
                result.lstGroup.forEach { (groupResponse) in
                    dispatchGroup.enter()
                    let lstClientID = groupResponse.lstClient.map{ GroupMember(id: $0.id, username: $0.displayName)}
                    let groupModel = GroupModel(groupID: groupResponse.groupID,
                                                groupName: groupResponse.groupName,
                                                groupToken: groupResponse.groupRtcToken,
                                                groupAvatar: groupResponse.groupAvatar,
                                                groupType: groupResponse.groupType,
                                                createdByClientID: groupResponse.createdByClientID,
                                                createdAt: groupResponse.createdAt,
                                                updatedByClientID: groupResponse.updatedByClientID,
                                                lstClientID: lstClientID,
                                                updatedAt: groupResponse.updatedAt,
                                                lastMessageAt: 0,
                                                lastMessage: Data(),
                                                idLastMessage: "",
                                                timeSyncMessage: 0)
                    RealmManager.shared.addAndUpdateGroup(group: groupModel) {
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: DispatchQueue.main) {
                    self.reloadData()
                }
            }
        }
    }
    
    func getGroupName(group: GroupModel) -> String {
        var userNameLogin = UserDefaults.standard.string(forKey: Constants.keySaveUser) ?? ""
        userNameLogin = group.groupName.replacingOccurrences(of: userNameLogin, with: "")
        userNameLogin = userNameLogin.replacingOccurrences(of: "-", with: "")
        return group.groupType == "peer" ? getPeerReceiveName(inGroup: group) : group.groupName
    }
    
    func getGroupUnreadMessageNumber(group: GroupModel) -> Int {
        // TODOP: to implement this later
        return 0//Int.random(in: 0...20)
    }
    
    func getGroupAvatarImage(group: GroupModel) -> Image? {
        // TODOP: to implement this later
        return nil
    }
    
    func getGroupOnlineStatus(group: GroupModel) -> UserOnlineStatus {
        // TODOP: to implement this later
        return .none
    }
    
    func getPeerReceiveName(inGroup group: GroupModel) -> String {
        let userLoginID = UserDefaults.standard.string(forKey: Constants.keySaveUserID) ?? ""
        if let member = group.lstClientID.filter({$0.id != userLoginID}).first {
            return member.username
        }
        return group.groupName
    }
    
    func getClientIdFriend(listClientID: [String]) -> String {
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            let idFriend = listClientID.filter {$0 != myAccount.username}
            return idFriend.isEmpty ? "" : idFriend[0]
        }
        return ""
    }
    
    private func convertedAndSortedGroup(_ realmGroups: [RealmGroup]) -> (groups: [GroupModel], peers: [GroupModel]) {
        var convertedGroups: [GroupModel] = []
        var convertedPeers: [GroupModel] = []
        
        for realmGroup in realmGroups {
            var lstClientId = Array<GroupMember>()
            realmGroup.lstClientID.forEach { (member) in
                lstClientId.append(GroupMember(id: member.id, username: member.displayName))
            }
            
            let group = GroupModel(groupID: realmGroup.groupId,
                                   groupName: realmGroup.groupName,
                                   groupToken: realmGroup.groupToken,
                                   groupAvatar: realmGroup.avatarGroup,
                                   groupType: realmGroup.groupType,
                                   createdByClientID: realmGroup.createdByClientID,
                                   createdAt: realmGroup.createdAt,
                                   updatedByClientID: realmGroup.updatedByClientID,
                                   lstClientID: lstClientId,
                                   updatedAt: realmGroup.updatedAt,
                                   lastMessageAt: realmGroup.lastMessageAt,
                                   lastMessage: realmGroup.lastMessage,
                                   idLastMessage: realmGroup.idLastMsg,
                                   isRegistered: realmGroup.isRegistered,
                                   timeSyncMessage: realmGroup.timeSyncMessage)
            if group.groupType == "peer" {
                convertedPeers.append(group)
            } else {
                convertedGroups.append(group)
            }
        }
        let convertedAndSortedPeers = convertedPeers.sorted { (gr1, gr2) -> Bool in
            return gr1.updatedAt > gr2.updatedAt
        }
        let convertedAndSortedGroups = convertedGroups.sorted { (gr1, gr2) -> Bool in
            return gr1.updatedAt > gr2.updatedAt
        }
        return (convertedAndSortedGroups, convertedAndSortedPeers)
    }
}

