//
//  GroupChatDetailView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/22/21.
//

import SwiftUI

struct GroupChatDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        
    var groupModel: GroupModel? = nil
    
    init(groupModel: GroupModel?) {
        self.groupModel = groupModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
                .frame(height: 30)

            HStack {
                Spacer()
                                
                VStack(alignment: .center, spacing: 16) {
                    LetterAvatarView(text: groupModel?.groupName ?? "Group")
                    
                    Text(groupModel?.groupName ?? "Group")
                        .font(.headline)
                }
                
                Spacer()
            }
            
            Spacer()
                .frame(height: 16)
            
            Text("Other features")
            
            NavigationLink(
                destination: GroupChatAddMember(),
                label: {
                    HStack {
                        Image(systemName: "person.badge.plus.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40, alignment: .center)
                        
                        VStack(alignment: .leading) {
                            Text("Add members")
                        }
                    }
                    .foregroundColor(.primary)
                })

            NavigationLink(
                destination: GroupChatMemberView(groupModel: groupModel),
                label: {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40, alignment: .center)
                        
                        VStack(alignment: .leading) {
                            Text("Show members")
                        }
                    }
                    .foregroundColor(.primary)
                })

            Spacer()
        }
        .padding()
        .navigationBarTitle(Text((groupModel?.groupName ?? "Group") + " details"), displayMode: .inline)
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: Button(action: {
//            self.presentationMode.wrappedValue.dismiss()
//        }, label: {
//            HStack {
//                Image(systemName: "chevron.left")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 18, height: 18, alignment: .leading)
//                    .foregroundColor(.blue)
//            }
//            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 20))
//        }))
    }
}

struct GroupChatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatDetailView(groupModel: nil)
    }
}
