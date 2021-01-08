//
//  MessageChat.swift
//  ClearKeep
//
//  Created by VietAnh on 10/30/20.
//

import SwiftUI

struct MessageChatView: View {
    
    @State private var nextMessage: String = ""
    @State var isShowCall = false
    @ObservedObject var viewModel: MessageChatViewModel
    
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var realmMessages : RealmMessages
    
    var ourEncryptionManager: CKAccountSignalEncryptionManager?
    
    private let userName: String
    
    private let clientId: String
    private var groupID: String
    
    @State var myGroupID: String = ""
    
    @State var messages = [MessageModel]()
    
    init(clientId: String , groupID: String, userName: String ) {
        self.userName = userName
        self.clientId = clientId
        self.groupID = groupID
        viewModel = MessageChatViewModel()
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
    }
    
    var body: some View {
        VStack {
            List(self.realmMessages.allMessageInGroup(groupId: self.myGroupID), id: \.id) { model in
                MessageView(mesgModel: model,chatWithUserID: self.clientId,chatWithUserName: self.userName)
            }
            .navigationBarTitle(Text(self.userName))
            .navigationBarItems(trailing: Button(action: {
                // CallManager call
                viewModel.callPeerToPeer(self.clientId, self.groupID)
            }, label: {
                Image(systemName: "phone")
            }))
            HStack {
                TextFieldContent(key: "Next message", value: self.$nextMessage)
                Button( action: {
                    self.send()
                }){
                    Image(systemName: "paperplane")
                }.padding(.trailing)
            }.onAppear() {
                UserDefaults.standard.setValue(true, forKey: Constants.isChatRoom)
                self.myGroupID = groupID
                self.viewModel.requestBundleRecipient(byClientId: self.clientId)
                self.realmMessages.loadSavedData()
                self.groupRealms.loadSavedData()
                self.reloadData()
                self.getMessageInRoom()
            }
            .onDisappear(){
                UserDefaults.standard.setValue(false, forKey: Constants.isChatRoom)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage)) { (obj) in
                if UserDefaults.standard.bool(forKey: Constants.isChatRoom) {
                    self.didReceiveMessage(userInfo: obj.userInfo)
                }
            }
        }
    }
}

extension MessageChatView {
    
    func didReceiveMessage(userInfo: [AnyHashable : Any]?) {
        if let userInfo = userInfo,
           let clientId = userInfo["clientId"] as? String,
           let publication = userInfo["publication"] as? Message_MessageObjectResponse,
           //            publication.groupID.isEmpty,
           clientId == self.clientId {
            
            if !realmMessages.isExistMessage(msgId: publication.id){
                if let ourEncryptionMng = self.ourEncryptionManager {
                    do {
                        let decryptedData = try ourEncryptionMng.decryptFromAddress(publication.message,
                                                                                    name: clientId,
                                                                                    deviceId: UInt32(111))
                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
                        print("Message decryption: \(messageDecryption ?? "Empty error")")
                        
                        DispatchQueue.main.async {
                            let post = MessageModel(id: publication.id,
                                                    groupID: publication.groupID,
                                                    groupType: publication.groupType,
                                                    fromClientID: publication.fromClientID,
                                                    clientID: publication.clientID,
                                                    message: decryptedData,
                                                    createdAt: publication.createdAt,
                                                    updatedAt: publication.updatedAt)
                            self.realmMessages.add(message: post)
                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: decryptedData)
                        }
                    } catch {
                        print("Decryption message error: \(error)")
                    }
                }
            }
        }
        self.messages = self.realmMessages.allMessageInGroup(groupId: self.myGroupID)
    }
    
    func getMessageInRoom(){
        if !self.groupID.isEmpty {
            Backend.shared.getMessageInRoom(self.groupID , self.realmMessages.getTimeStampPreLastMessage(groupId: self.groupID)) { (result, error) in
                if let result = result {
                    result.lstMessage.forEach { (message) in
                        let filterMessage = self.realmMessages.allMessageInGroup(groupId: message.groupID).filter{$0.id == message.id}
                        if filterMessage.isEmpty {
                            if let ourEncryptionMng = self.ourEncryptionManager {
                                do {
                                    let decryptedData = try ourEncryptionMng.decryptFromAddress(message.message,
                                                                                                name: self.clientId,
                                                                                                deviceId: UInt32(111))
                                    let messageDecryption = String(data: decryptedData, encoding: .utf8)
                                    print("Message decryption: \(messageDecryption ?? "Empty error")")
                                    
                                    DispatchQueue.main.async {
                                        let post = MessageModel(id: message.id,
                                                                groupID: message.groupID,
                                                                groupType: message.groupType,
                                                                fromClientID: message.fromClientID,
                                                                clientID: message.clientID,
                                                                message: decryptedData,
                                                                createdAt: message.createdAt,
                                                                updatedAt: message.updatedAt)
                                        self.realmMessages.add(message: post)
                                        self.myGroupID = message.groupID
                                        self.reloadData()
                                    }
                                } catch {
                                    print("Decryption message error: \(error)")
                                }
                            }
                        }
                    }
                    self.reloadData()
                }
            }
        }
    }
    
    private func reloadData(){
        DispatchQueue.main.async {
            self.messages = self.realmMessages.allMessageInGroup(groupId: self.myGroupID)
        }
    }
    
    
    private func send() {
        self.sendMessage(messageStr: $nextMessage.wrappedValue)
        nextMessage = ""
    }
    
    func sendMessage(messageStr: String) {
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            do {
                //                self.viewModel.requestBundleRecipient(byClientId: clientId)
                
                guard let encryptedData = try ourEncryptionManager?.encryptToAddress(payload,
                                                                                     name: clientId,
                                                                                     deviceId: self.viewModel.recipientDeviceId) else { return }
                if self.myGroupID.isEmpty {
                    
                    var req = Group_CreateGroupRequest()
                    let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserNameLogin) ?? "") as String
                    req.groupName = "\(self.userName)-\(userNameLogin)"
                    req.groupType = "peer"
                    req.createdByClientID = myAccount.username
                    req.lstClientID = [myAccount.username , self.clientId]
                    
                    Backend.shared.createRoom(req) { (result) in
                        let lstClientID = result.lstClient.map{$0.id}
                        
                        DispatchQueue.main.async {
                            let group = GroupModel(groupID: result.groupID,
                                                   groupName: result.groupName,
                                                   groupAvatar: result.groupAvatar,
                                                   groupType: result.groupType,
                                                   createdByClientID: result.createdByClientID,
                                                   createdAt: result.createdAt,
                                                   updatedByClientID: result.updatedByClientID,
                                                   lstClientID: lstClientID,
                                                   updatedAt: result.updatedAt,
                                                   lastMessageAt: result.lastMessageAt,
                                                   lastMessage: payload)
                            self.groupRealms.add(group: group)
                        }

                        self.myGroupID = result.groupID
                        
                        Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, toClientId: self.clientId , groupId: self.myGroupID , groupType: "peer") { (result) in
                            if let result = result {
                                DispatchQueue.main.async {
                                    let post = MessageModel(id: result.id,
                                                            groupID: result.groupID,
                                                            groupType: result.groupType,
                                                            fromClientID: result.fromClientID,
                                                            clientID: result.clientID,
                                                            message: payload,
                                                            createdAt: result.createdAt,
                                                            updatedAt: result.updatedAt)
                                    self.realmMessages.add(message: post)
                                    self.reloadData()
                                }
                            }
                        }
                    }
                } else {
                    Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, toClientId: self.clientId , groupId: self.myGroupID , groupType: "peer") { (result) in
                        if let result = result {
                            DispatchQueue.main.async {
                                let post = MessageModel(id: result.id,
                                                        groupID: result.groupID,
                                                        groupType: result.groupType,
                                                        fromClientID: result.fromClientID,
                                                        clientID: result.clientID,
                                                        message: payload,
                                                        createdAt: result.createdAt,
                                                        updatedAt: result.updatedAt)
                                self.realmMessages.add(message: post)
                                self.groupRealms.updateLastMessage(groupID: self.myGroupID, lastMessage: payload)
                                self.reloadData()
                            }
                        }
                    }
                }
                
            } catch {
                print("Send message error: \(error)")
            }
        }
        self.reloadData()
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
    static var previews: some View {
        MessageChatView(clientId: "" , groupID: "", userName: "").environmentObject(RealmGroups()).environmentObject(RealmMessages())
    }
}
