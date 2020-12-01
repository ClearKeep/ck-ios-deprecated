//
//  GroupMessageChatView.swift
//  ClearKeep
//
//  Created by VietAnh on 11/5/20.
//

import SwiftUI

struct GroupMessageChatView<GenericMessages: MessageChats>: View {
    @State private var nextMessage: String = ""
    @ObservedObject var viewModel: GroupMessageChatViewModel
    
    private let selectedRoom: String
    @ObservedObject var messages: GenericMessages
    
    init(groupId: String , messages: GenericMessages) {
        self.selectedRoom = groupId
        self.messages = messages
        viewModel = GroupMessageChatViewModel(groupId: groupId)
    }
    
    var body: some View {
        VStack {
            List(messages.allMessageInGroup(groupId: selectedRoom), id: \.id) { model in
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
    static let messages = [MessageModel]()
    class PreviewMessages: MessageChats {
        
        @Published private(set) var all: [MessageModel]
        var allPublished: Published<[MessageModel]> { _all }
        var allPublisher: Published<[MessageModel]>.Publisher { $all }
        init(messages: [MessageModel]) { self.all = messages }
        func add(message: MessageModel) { }
        func insert() { }
        func update(message: MessageModel) { }
        func remove(messageRemove: MessageModel) { }
        func allMessageInGroup(groupId: String) -> [MessageModel] {
            return all.filter{$0.groupID == groupId}
        }
        
    }
    
    static var previews: some View {
        GroupMessageChatView(groupId: "" ,messages: PreviewMessages(messages: messages))
    }
}
