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
        VStack(alignment: .leading , spacing: 0) {
            Group {
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(alignment:.leading , spacing: 16) {
                        if let groupMembers = groupModel?.lstClientID {
                            let peoples = groupMembers.map {People(id: $0.id, userName: $0.username, userStatus: .Online)}
                            ForEach(peoples , id: \.id) { user in
                                ContactView(people: user)
                            }
                        }
                        
                    }
                })
            }
            .padding(.top, 24)
            .padding(.horizontal)
        }
        .applyNavigationBarPlainStyleDark(title: "Member", leftBarItems: {
            ButtonBack(action: {
                presentationMode.wrappedValue.dismiss()
            })
        }, rightBarItems: {
            Spacer()
        })
    }
}

struct GroupChatMemberView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatMemberView(groupModel: nil)
    }
}
