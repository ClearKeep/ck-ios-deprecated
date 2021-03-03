//
//  MessageChat.swift
//  ClearKeep
//
//  Created by VietAnh on 10/30/20.
//

import SwiftUI
import AVFoundation

struct MessageChatView: View {
    
    @State var isShowCall = false
    @ObservedObject var viewModel: MessageChatViewModel = MessageChatViewModel()
    
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var realmMessages : RealmMessages
    
    var ourEncryptionManager: CKAccountSignalEncryptionManager?
    private let userName: String
    private let groupType: String
    private let clientId: String
    private let groupId: Int64
    
    @State var myGroupID: Int64 = 0
    
    @State var messages = [MessageModel]()
    @State var messageStr = ""
    @State var hudVisible = false
    @State var alertVisible = false
    private let scrollingProxy = ListScrollingProxy()
    
    init(clientId: String, groupID: Int64, userName: String, groupType: String = "peer") {
        self.userName = userName
        self.clientId = clientId
        self.groupType = groupType
        self.groupId = groupID
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
    }
    
    var body: some View {
        VStack {
            if #available(iOS 14.0, *) {
                GeometryReader { reader in
                    ScrollView(.vertical, showsIndicators: false, content: {
                        HStack { Spacer() }
                        ScrollViewReader{reader in
                            LazyVStack(spacing: 20){
                                ForEach(realmMessages.allMessageInGroup(groupId: self.myGroupID)) { msg in
                                    // Chat Bubbles...
                                    MessageBubble(msg: msg)
                                        .id(msg.id)
                                }
                            }
                            .onChange(of: realmMessages.allMessageInGroup(groupId: self.myGroupID).count) { _ in
                                reader.scrollTo(self.getIdLastItem(), anchor: .bottom)
                            }
                            .onAppear(perform: {
                                reader.scrollTo(self.getIdLastItem(), anchor: .bottom)
                            })
                            .padding([.horizontal,.bottom])
                            .padding(.top, 25)
                        }
                    })
                }
            }else {
                GeometryReader { reader in
                    ScrollView(.vertical, showsIndicators: false, content: {
                        HStack { Spacer() }
                        VStack(spacing: 20){
                            ForEach(realmMessages.allMessageInGroup(groupId: self.myGroupID)) { msg in
                                // Chat Bubbles...
                                MessageBubble(msg: msg)
                                    .id(msg.id)
                                    .background (
                                        ListScrollingHelper(proxy: self.scrollingProxy)
                                    )
                            }
                        }
                        .onAppear(perform: {
                            self.reloadData()
                        })
                        .padding([.horizontal,.bottom])
                        .padding(.top, 25)
                    })
                }
            }
            
            HStack(spacing: 15){
                HStack(spacing: 15){
                    TextField("Message", text: $messageStr)
                        //                        .foregroundColor(.black)
                        .offset()
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(Color.black.opacity(0.06))
                .clipShape(Capsule())
                
                // Send Button...
                // hiding view...
                if messageStr != ""{
                    Button(action: {
                        // appeding message...
                        // adding animation...
                        withAnimation(.easeIn){
                            self.send()
                        }
                        messageStr = ""
                    }, label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color.blue)
                            // adjusting padding shape...
                            .padding(.vertical,12)
                            .padding(.leading,12)
                            .padding(.trailing,17)
                            .background(Color.black.opacity(0.07))
                            .clipShape(Circle())
                    })
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .animation(.easeOut)
        }
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .navigationBarTitle(Text(self.userName))
        .navigationBarItems(trailing: Button(action: {
            
            AVCaptureDevice.authorizeVideo(completion: { (status) in
                AVCaptureDevice.authorizeAudio(completion: { (status) in
                    if status == .alreadyAuthorized || status == .justAuthorized {
                        hudVisible = true
                        // CallManager call
                        if let group = groupRealms.getGroup(clientId: clientId, type: groupType) {
                            viewModel.callPeerToPeer(group: group, clientId: clientId) {
                                hudVisible = false
                            }
                        } else {
                            viewModel.createGroup(username: self.userName, clientId: self.clientId) { (group) in
                                viewModel.callPeerToPeer(group: group, clientId: clientId) {
                                    hudVisible = false
                                }
                            }
                        }
                    } else {
                        self.alertVisible = true
                    }
                })
            })
            
        }, label: {
            Image(systemName: "video")
        }))
        .alert(isPresented: $alertVisible, content: {
            Alert (title: Text("Need camera and microphone permissions"),
                   message: Text("Go to Settings?"),
                   primaryButton: .default(Text("Settings"), action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                   }),
                   secondaryButton: .default(Text("Cancel")))
        })
        // since bottom edge is ignored....
        //        .padding(.bottom,UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        //        .background(Color.white)
        .onAppear() {
            UserDefaults.standard.setValue(true, forKey: Constants.isChatRoom)
            viewModel.setup(clientId: clientId, groupId: groupId, groupType: groupType)
            if viewModel.groupId == 0, let group = groupRealms.getGroup(clientId: clientId, type: groupType) {
                viewModel.groupId = group.groupID
            }
            self.myGroupID = viewModel.groupId
            self.viewModel.requestBundleRecipient(byClientId: self.clientId){}
            self.realmMessages.loadSavedData()
            self.groupRealms.loadSavedData()
            self.getMessageInRoom()
            self.reloadData()
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

extension MessageChatView {
    
    func getIdLastItem() -> String {
        let msgInRoom = realmMessages.allMessageInGroup(groupId: self.myGroupID)
        var id = ""
        if msgInRoom.count > 0 {
            id = msgInRoom[msgInRoom.count - 1].id
        }
        return id
    }
    
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
                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: decryptedData, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                            self.reloadData()
                        }
                    } catch {
                        //save message error when can't decrypt
                        DispatchQueue.main.async {
                            let messageError = "unable to decrypt this message".data(using: .utf8) ?? Data()
                            
                            let post = MessageModel(id: publication.id,
                                                    groupID: publication.groupID,
                                                    groupType: publication.groupType,
                                                    fromClientID: publication.fromClientID,
                                                    clientID: publication.clientID,
                                                    message: messageError,
                                                    createdAt: publication.createdAt,
                                                    updatedAt: publication.updatedAt)
                            self.realmMessages.add(message: post)
                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: messageError, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                            self.reloadData()
                        }
                        print("Decryption message error: \(error)")
                    }
                }
            }
        }
    }
    
    func getMessageInRoom(){
        if viewModel.groupId != 0 {
            Backend.shared.getMessageInRoom(viewModel.groupId,
                                            self.realmMessages.getTimeStampPreLastMessage(groupId: viewModel.groupId)) { (result, error) in
                if let result = result {
                    result.lstMessage.forEach { (message) in
                        let filterMessage = self.realmMessages.allMessageInGroup(groupId: message.groupID).filter{$0.id == message.id}
                        if filterMessage.isEmpty {
                            if let ourEncryptionMng = self.ourEncryptionManager {
                                do {
                                    let decryptedData = try ourEncryptionMng.decryptFromAddress(message.message,
                                                                                                name: self.clientId,
                                                                                                deviceId: UInt32(555))
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
                                        self.groupRealms.updateLastMessage(groupID: message.groupID, lastMessage: decryptedData, lastMessageAt: message.createdAt, idLastMessage: message.id)
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
            self.realmMessages.loadSavedData()
            self.scrollingProxy.scrollTo(.end)
        }
    }
    
    
    private func send() {
        self.sendMessage(messageStr: $messageStr.wrappedValue)
        //        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func sendMessage(messageStr: String) {
        
        if messageStr.trimmingCharacters(in: .whitespaces).isEmpty {
            return
        }
        
        
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        self.viewModel.requestBundleRecipient(byClientId: clientId) {
            if let myAccount = CKSignalCoordinate.shared.myAccount {
                do {
                    guard let encryptedData = try ourEncryptionManager?.encryptToAddress(payload,
                                                                                         name: clientId,
                                                                                         deviceId: self.viewModel.recipientDeviceId) else { return }
                    if viewModel.groupId == 0, let group = groupRealms.getGroup(clientId: clientId, type: groupType) {
                        viewModel.groupId = group.groupID
                        self.myGroupID = group.groupID
                    }
                    if viewModel.groupId == 0 {
                        viewModel.createGroup(username: self.userName, clientId: clientId) { (group) in
                            self.groupRealms.add(group: group)
                            self.myGroupID = group.groupID
                            
                            Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, toClientId: self.clientId , groupId: viewModel.groupId , groupType: groupType) { (result) in
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
                                        self.groupRealms.updateLastMessage(groupID: group.groupID, lastMessage: payload, lastMessageAt: result.createdAt, idLastMessage: result.id)
                                        self.reloadData()
                                        self.scrollingProxy.scrollTo(.end)
                                    }
                                }
                            }
                        }
                    } else {
                        Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, toClientId: self.clientId , groupId: viewModel.groupId , groupType: groupType) { (result) in
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
                                    self.groupRealms.updateLastMessage(groupID: viewModel.groupId, lastMessage: payload, lastMessageAt: result.createdAt, idLastMessage: result.id)
                                    self.reloadData()
                                    self.scrollingProxy.scrollTo(.end)
                                }
                            }
                        }
                    }
                    
                } catch {
                    print("Send message error: \(error)")
                }
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
            //
            //            let senderView: HStack = HStack(alignment: .top, spacing: 8) {
            //                Text(sender()).bold().foregroundColor(Color.red)
            //                Text(stringValue()).alignmentGuide(.trailing) { d in
            //                    d[.leading]
            //                }
            //            }
            
            return ChatBubble(direction: .left) {
                Text(stringValue())
                    .padding(.all, 5)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
            }
            
        } else {
            
            //            let receiveView: HStack = HStack(alignment: .top, spacing: 8) {
            //                Text(sender()).bold().foregroundColor(Color.green)
            //                Text(stringValue()).alignmentGuide(.trailing) { d in
            //                    d[.trailing]
            //                }
            //            }
            
            return ChatBubble(direction: .right) {
                Text(stringValue())
                    .padding(.all, 5)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
            }
        }
    }
    
    private func stringValue() -> String {
        return String(data: mesgModel.message, encoding: .utf8) ?? "x"
    }
    
    private func sender() -> String {
        let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserID) ?? "") as String
        let myAccount = CKSignalCoordinate.shared.myAccount?.username ?? ""
        
        if isGroup {
            return mesgModel.fromClientID == myAccount ? userNameLogin : mesgModel.fromClientID
        }
        return mesgModel.fromClientID == self.chatWithUserID ? self.chatWithUserName : userNameLogin
    }
}

struct MessageChat_Previews: PreviewProvider {
    static var previews: some View {
        MessageChatView(clientId: "" , groupID: 0, userName: "").environmentObject(RealmGroups()).environmentObject(RealmMessages())
    }
}
