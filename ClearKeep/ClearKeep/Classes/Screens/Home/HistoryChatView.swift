//
//  HistoryChatView.swift
//  ClearKeep
//
//  Created by Seoul on 11/18/20.
//

import SwiftUI

struct HistoryChatView<GenericGroups: GroupChats>: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var viewModel = HistoryChatViewModel()
    @ObservedObject var groups: GenericGroups
    
    @State var pushActive = false
    
    var body: some View {
        
        NavigationView {
            List(groups.all , id: \.groupID){ group in
                    let viewPeer = MessageChatView(clientId: viewModel.getClientIdFriend(listClientID: group.lstClientID),
                                                   userName: viewModel.getGroupName(group: group),
                                                   messages: RealmMessages())

                    let viewGroup = GroupMessageChatView(groupId: group.groupID ,messages: RealmMessages())
                    
                    if group.groupType == "peer" {
                        NavigationLink(destination:  viewPeer) {
                            Image(systemName: group.groupType == "peer" ? "person.fill" : "person.3.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text(viewModel.getGroupName(group: group))
                                Text(group.createdByClientID)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }else {
                        NavigationLink(destination:  viewGroup) {
                            Image(systemName: group.groupType == "peer" ? "person.fill" : "person.3.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text(viewModel.getGroupName(group: group))
                                Text(group.createdByClientID)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }.onAppear {
//                    viewModel.getJoinedGroup()
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
                                
                                if self.groups.isExistGroup(findGroup: groupModel) {
                                    DispatchQueue.main.async {
                                        self.groups.update(group: groupModel)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.groups.add(group: groupModel)
                                    }
                                }
                            }
                        }
                    }
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(leading: Text("Chat"), trailing: Button(action: {
                self.pushActive = true
            }, label: {
                NavigationLink(destination: CreateRoomView() , isActive: self.$pushActive) { }
                Text("Create Room")
            }))
        }
    }
    
}

struct HistoryChatView_Previews: PreviewProvider {
    
    static let groups = [GroupModel]()
    
    class PreviewGroups: GroupChats {
        
        @Published private(set) var all: [GroupModel]
        var allPublished: Published<[GroupModel]> { _all }
        var allPublisher: Published<[GroupModel]>.Publisher { $all }
        init(groups: [GroupModel]) { self.all = groups }
        func add(group: GroupModel) { }
        func insert() { }
        func update(group: GroupModel) { }
        func remove(groupRemove: GroupModel) { }
        func isExistGroup(findGroup: GroupModel) -> Bool {
            return !all.filter{$0.id == findGroup.id}.isEmpty
        }
        
    }
    
    
    
    static var previews: some View {
        HistoryChatView(groups: PreviewGroups(groups: groups))
    }
}
