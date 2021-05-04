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
        NavigationView {
            VStack(alignment: .leading , spacing: 0) {
                Spacer().frame(width: UIScreen.main.bounds.width, height: 68)
                
                HStack(spacing: 16){
                    Image("Chev-left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24, alignment: .leading)
                        .foregroundColor(AppTheme.colors.black.color)
                        .onTapGesture(count: 1, perform: {
                            presentationMode.wrappedValue.dismiss()
                        })
                    
                    Text("Member")
                        .font(AppTheme.fonts.linkLarge.font)
                        .foregroundColor(AppTheme.colors.black.color)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                
                
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
                }.padding(.horizontal)
                
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.top)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
}

struct GroupChatMemberView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatMemberView(groupModel: nil)
    }
}
