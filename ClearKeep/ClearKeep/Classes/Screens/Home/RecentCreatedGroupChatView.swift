//
//  RecentCreatedGroupChatView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/26/21.
//

import SwiftUI

struct RecentCreatedGroupChatView: View {
    
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var messsagesRealms : RealmMessages
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        NavigationView {
            VStack {
                GroupMessageChatView(groupModel: self.viewRouter.recentCreatedGroupModel!).environmentObject(self.groupRealms).environmentObject(self.messsagesRealms)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: HStack {
                HStack {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18, alignment: .leading)
                        .foregroundColor(.blue)
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 20))
                .onTapGesture {
                    self.viewRouter.current = .tabview
                }
                
                NavigationLink(
                    destination: GroupChatDetailView(groupModel: self.viewRouter.recentCreatedGroupModel!),
                    label: {
                        Text(self.viewRouter.recentCreatedGroupModel!.groupName)
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                            .frame(width: UIScreen.main.bounds.width - 100, alignment: .center)
                    })
            })
            
        }
    }
}

struct RecentCreatedGroupChatView_Previews: PreviewProvider {
    static var previews: some View {
        RecentCreatedGroupChatView()
    }
}
