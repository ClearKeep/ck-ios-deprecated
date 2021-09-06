//
//  CreateRoomViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import Foundation

class CreateRoomViewModel: ObservableObject, Identifiable {
    
    // MARK: - Variables
    private(set) var listMembers: [People] = []
    
    // MARK: - Init & Setup
    
    func setup(listMembers: [People]) {
        self.listMembers = listMembers
    }
    
    // MARK: - API
    func createRoom(groupName: String, completion: ((Int64) -> ())? = nil) {
        var lstClientID = self.listMembers.map{ GroupMember(id: $0.id, username: $0.userName)}
        
        if let account = CKSignalCoordinate.shared.myAccount {
            let userLogin = Multiserver.instance.currentServer.getUserLogin()
            lstClientID.append(GroupMember(id: account.username, username: userLogin?.displayName ?? account.username))
            var req = Group_CreateGroupRequest()
            req.groupName = groupName
            req.groupType = "group"
            req.createdByClientID = account.username
//            req.lstClientID = lstClientID.map{$0.id}
            
            Multiserver.instance.currentServer.createRoom(req) { (result , error) in
                if let result = result {
                    DispatchQueue.main.async {
                        let group = GroupModel(groupID: result.groupID,
                                               groupName: result.groupName,
                                               groupToken: result.groupRtcToken,
                                               groupAvatar: result.groupAvatar,
                                               groupType: result.groupType,
                                               createdByClientID: result.createdByClientID,
                                               createdAt: result.createdAt,
                                               updatedByClientID: result.updatedByClientID,
                                               lstClientID: lstClientID,
                                               updatedAt: result.updatedAt,
                                               lastMessageAt: result.lastMessageAt,
                                               lastMessage: Data(),
                                               idLastMessage: result.lastMessage.id,
                                               timeSyncMessage: 0)
                        RealmManager.shared.addAndUpdateGroup(group: group) {
                            completion?(result.groupID)
                        }
                    }
                }
                completion?(0)
            }
        }
    }
}
