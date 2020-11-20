//
//  GroupMessageChatView.swift
//  ClearKeep
//
//  Created by VietAnh on 11/5/20.
//

import SwiftUI

struct GroupMessageChatView: View {
    @State private var nextMessage: String = ""
    @ObservedObject var viewModel: GroupMessageChatViewModel
    
    private let selectedRoom: String
    
    init(groupId: String) {
        self.selectedRoom = groupId
        viewModel = GroupMessageChatViewModel(groupId: groupId)
    }
    
    var body: some View {
        VStack {
            List(viewModel.messages, id: \.newID) { model in
                MessageView(mesgModel: model, chatWithUserID: "", chatWithUserName: "")
            }
            .navigationBarTitle(Text(self.selectedRoom))
            HStack {
                TextFieldContent(key: "Next message", value: self.$nextMessage)
                Button( action: {
                    self.send()
                }){
                    Image(systemName: "paperplane")
                }.padding(.trailing)
            }.onAppear() {
                self.viewModel.messages.removeAll()
            }
        }
    }
}

extension GroupMessageChatView {
    private func send() {
        viewModel.send(messageStr: $nextMessage.wrappedValue)
        nextMessage = ""
    }
}

struct GroupMessageChatView_Previews: PreviewProvider {
    static var previews: some View {
        GroupMessageChatView(groupId: "")
    }
}
