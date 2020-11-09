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
    
    init(clientId: String) {
        self.selectedRoom = clientId
        viewModel = MessageChatViewModel(clientId: clientId)
    }
    
    var body: some View {
        VStack {
            List(viewModel.messages, id: \.newID) { model in
                MessageView(mesgModel: model)
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

extension MessageChatView {
    
    private func send() {
        viewModel.send(messageStr: $nextMessage.wrappedValue)
        nextMessage = ""
    }
}

struct MessageView: View {
    
    var mesgModel: MessageModel
    
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
        return mesgModel.from
    }
}

struct MessageChat_Previews: PreviewProvider {
    static var previews: some View {
        MessageChatView(clientId: "")
    }
}
