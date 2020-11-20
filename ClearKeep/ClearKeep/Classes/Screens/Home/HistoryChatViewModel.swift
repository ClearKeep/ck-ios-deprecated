//
//  HistoryChatViewModel.swift
//  ClearKeep
//
//  Created by Seoul on 11/19/20.
//

import SwiftUI

class HistoryChatViewModel: ObservableObject, Identifiable {
    
    @Published var groups : [GroupModel] = []
    
    func getJoinedGroup(){
        Backend.shared.getJoinnedGroup { (result, error) in
            if let result = result {
                DispatchQueue.main.async {
                    self.groups.removeAll()
                    result.lstGroup.forEach { (group) in
                        self.groups.append(GroupModel(id: "", groupID: group.groupID, groupName: group.groupName, groupAvatar: group.groupAvatar, groupType: group.groupType, createdByClientID: group.createdByClientID, createdAt: group.createdAt, updatedByClientID: group.updatedByClientID, lstClientID: group.lstClientID, updatedAt: group.updatedAt))
                    }
                }
            }
        }
    }
}
