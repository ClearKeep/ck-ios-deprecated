//
//  GroupChatMemberView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/23/21.
//

import SwiftUI

struct GroupChatMemberView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var groupModel: GroupModel? = nil
    
    init(groupModel: GroupModel?) {
        self.groupModel = groupModel
    }
    
    var body: some View {
        let currentUserId = Backend.shared.getUserLogin()?.id ?? ""
        
        VStack {
            if let groupMembers = groupModel?.lstClientID {
                List(groupMembers) { groupMember in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                        
                        VStack(alignment: .leading) {
                            
                            if groupMember.id == currentUserId {
                                Text(Backend.shared.getUserLogin()?.displayName ?? "me")
                            } else {
                                Text(groupMember.username)
                            }
                        }
                    }
                }
            }
        }
//        .navigationBarTitle("Group members")
        .navigationBarTitle(Text("Group members"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18, alignment: .leading)
                    .offset(x: -10)
                    .foregroundColor(.blue)
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 20))
        }))
    }
}

struct GroupChatMemberView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatMemberView(groupModel: nil)
    }
}
