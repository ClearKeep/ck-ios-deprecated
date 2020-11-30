//
//  MessageChat.swift
//  ClearKeep
//
//  Created by VietAnh on 10/30/20.
//

import SwiftUI

struct MessageChatView: View {
    @State private var nextMessage: String = ""
    @ObservedObject var viewModel: MessageChatViewModel
    
    private let selectedRoom: String
    
    private let chatWithUserID: String
    
    init(clientId: String , userName : String) {
        self.selectedRoom = userName
        self.chatWithUserID = clientId
        viewModel = MessageChatViewModel(clientId: clientId,chatWithUser: userName)
    }
    
    var body: some View {
        VStack {
            List(viewModel.messages, id: \.newID) { model in
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
                self.viewModel.messages.removeAll()
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
        
        let checkSender = mesgModel.from == CKSignalCoordinate.shared.myAccount?.username
        
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
        return String(data: mesgModel.data, encoding: .utf8) ?? "x"
    }
    
    private func sender() -> String {
        let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserNameLogin) ?? "") as String
        let myAccount = CKSignalCoordinate.shared.myAccount?.username ?? ""
        
        if isGroup {
            return mesgModel.from == myAccount ? userNameLogin : mesgModel.from
        }
        return mesgModel.from == self.chatWithUserID ? self.chatWithUserName : userNameLogin
    }
}

struct MessageChat_Previews: PreviewProvider {
    static var previews: some View {
        MessageChatView(clientId: "" , userName: "")
    }
}
