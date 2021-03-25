//
//  GroupChatAddMember.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/24/21.
//

import SwiftUI

struct GroupChatAddMember: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        VStack {
            Text("Coming soon ...")
        }
        .navigationBarTitle(Text("Add members"), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18, alignment: .leading)
                    .foregroundColor(.blue)
            }
            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 20))
        }))
    }
}

struct GroupChatAddMember_Previews: PreviewProvider {
    static var previews: some View {
        GroupChatAddMember()
    }
}
