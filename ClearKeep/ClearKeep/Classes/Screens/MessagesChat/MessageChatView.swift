//
//  MessageChat.swift
//  ClearKeep
//
//  Created by VietAnh on 10/30/20.
//

import SwiftUI

struct MessageChatView<GenericMessages: MessageChats>: View {
    
    @State private var nextMessage: String = ""
    @ObservedObject var viewModel: MessageChatViewModel
    @ObservedObject var messages: GenericMessages
    
    
    private let selectedRoom: String
    
    private let chatWithUserID: String
        
    init(clientId: String , userName: String, messages: GenericMessages) {
        self.selectedRoom = userName
        self.chatWithUserID = clientId
        self.messages = messages
        viewModel = MessageChatViewModel(clientId: clientId,chatWithUser: userName)
    }
    
    var body: some View {
        VStack {
            List(messages.allMessageInGroup(groupId: selectedRoom), id: \.id) { model in
                MessageView(mesgModel: model,chatWithUserID: self.chatWithUserID,chatWithUserName: self.selectedRoom)
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
                self.viewModel.getMessageInRoom()
            }
        }
    }
}

extension MessageChatView {
    
    private func send() {
        viewModel.send(messageStr: $nextMessage.wrappedValue)
        nextMessage = ""
    }
}

struct MessageView: View {
    
    var mesgModel: MessageModel
    
    var chatWithUserID: String
    
    var chatWithUserName: String
    
    var isGroup = false
    
    var body: some View {
        
        let checkSender = mesgModel.fromClientID == CKSignalCoordinate.shared.myAccount?.username
        
        if checkSender {
            
            let senderView: HStack = HStack(alignment: .top, spacing: 8) {
                Text(sender()).bold().foregroundColor(Color.red)
                Text(stringValue()).alignmentGuide(.trailing) { d in
                    d[.leading]
                }
            }
            
            return senderView
            
        } else {
            
            let receiveView: HStack = HStack(alignment: .top, spacing: 8) {
                Text(sender()).bold().foregroundColor(Color.green)
                Text(stringValue()).alignmentGuide(.trailing) { d in
                    d[.trailing]
                }
            }
            
            return receiveView
        }
    }

    private func stringValue() -> String {
        return String(data: mesgModel.message, encoding: .utf8) ?? "x"
    }
    
    private func sender() -> String {
        let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserNameLogin) ?? "") as String
        let myAccount = CKSignalCoordinate.shared.myAccount?.username ?? ""
        
        if isGroup {
            return mesgModel.fromClientID == myAccount ? userNameLogin : mesgModel.fromClientID
        }
        return mesgModel.fromClientID == self.chatWithUserID ? self.chatWithUserName : userNameLogin
    }
}

struct MessageChat_Previews: PreviewProvider {
    
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
        MessageChatView(clientId: "" , userName: "", messages: PreviewMessages(messages: messages))
    }
}
