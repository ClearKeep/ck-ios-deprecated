//
//  RecentCreatedGroupChatView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/26/21.
//

import SwiftUI

struct RecentCreatedGroupChatView: View {
    
    @EnvironmentObject var realmGroups : RealmGroups
    @EnvironmentObject var messsagesRealms : RealmMessages
    
    let groupModel: GroupModel
    
    init(groupModel: GroupModel) {
        self.groupModel = groupModel
    }
    
    var body: some View {
        GroupMessageChatView(groupModel: groupModel).environmentObject(self.realmGroups).environmentObject(self.messsagesRealms)
    }
}

//struct RecentCreatedGroupChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecentCreatedGroupChatView()
//    }
//}
