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
            Group {
                List(groups.all , id: \.groupID){ group in
                    let viewPeer = MessageChatView(clientId: viewModel.getClientIdFriend(listClientID: group.lstClientID), userName: viewModel.getGroupName(group: group))
                    
                    let viewGroup = GroupMessageChatView(groupId: group.groupID)
                    
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
                    self.viewModel.getJoinedGroup()
                    
//                    Backend.shared.getJoinnedGroup { (result, error) in
//                        
//                    }
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
    }
    
    
    
    static var previews: some View {
        HistoryChatView(groups: PreviewGroups(groups: groups))
    }
}
