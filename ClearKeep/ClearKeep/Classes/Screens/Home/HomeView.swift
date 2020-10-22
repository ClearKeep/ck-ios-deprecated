//
//  HomeView.swift
//  ClearKeep
//
//  Created by LuongTiem on 10/7/20.
//

import SwiftUI
import SwiftProtobuf
import NIO
import GRPC


struct HomeView: View {
    
    @State private var nextMessage: String = ""
    
    private let selectedRoom: String
    
    @ObservedObject var resource = Backend.shared
    
    
    init(clientID: String) {
        self.selectedRoom = clientID
        
        Backend.shared.authenticator.login(clientID) { (result, error, response) in
            
            guard let recipientStore = response else {
                print("Request prekey \(clientID) fail")
                return
            }
            
            Backend.shared.authenticator.recipientID = recipientStore.clientID
            Backend.shared.authenticator.recipientStore = recipientStore
        }
    }
    
    
    var body: some View {
        List(resource.messages, id: \.newID) { landmark in
            PostView(postModel: landmark)
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
            self.resource.messages.removeAll()
        }
    }
    
}

extension HomeView {
    
    private func send() {
        
        guard let payload = $nextMessage.wrappedValue.data(using: .utf8) else {
            return
        }
        
        let post = PostModel(from: Backend.shared.authenticator.clientStore.address.name, message: payload)
        
        Backend.shared.messages.append(post)
        
        Backend.shared.send(nextMessage, to: selectedRoom) { (result, error) in
            
            print(result, " ----->")
            
        }
        
        nextMessage = ""
    }
}

struct PostView: View {
    
    var postModel: PostModel
    
    var body: some View {
        
        let checkSender = postModel.from == Backend.shared.authenticator.clientStore.address.name
        
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
        return String(data: postModel.message, encoding: .utf8) ?? "x"
    }
    
    private func sender() -> String {
        return postModel.from
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(clientID: "A Room with a View")
    }
}
