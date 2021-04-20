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
    
    @State private var scrollingProxy = ListScrollingProxy()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(clientId: String, groupID: Int64, userName: String, groupType: String = "peer") {
        self.userName = userName
        self.clientId = clientId
        self.groupType = groupType
        self.groupId = groupID
        viewModel.setup(clientId: clientId, username: self.userName, groupId: groupId, groupType: groupType)
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
    }
    
    var body: some View {
        VStack {
            customeNavigationBarView()
            messageListView()
            sendMessageBarView()
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .keyboardManagment()
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .alert(isPresented: $alertVisible, content: {
            Alert (title: Text("Need camera and microphone permissions"),
                   message: Text("Go to Settings?"),
                   primaryButton: .default(Text("Settings"), action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                   }),
                   secondaryButton: .default(Text("Cancel")))
        })
        .onAppear() {
            UserDefaults.standard.setValue(true, forKey: Constants.isChatRoom)
            if viewModel.groupId == 0, let group = groupRealms.getGroup(clientId: clientId, type: groupType) {
                viewModel.groupId = group.groupID
            }
            self.myGroupID = viewModel.groupId
            self.viewModel.requestBundleRecipient(byClientId: self.clientId){}
            DispatchQueue.main.async {
                self.realmMessages.loadSavedData()
                self.groupRealms.loadSavedData()
            }
            self.getMessageInRoom()
            self.reloadData()
        }
        .onDisappear(){
            UserDefaults.standard.setValue(false, forKey: Constants.isChatRoom)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage)) { (obj) in
            if UserDefaults.standard.bool(forKey: Constants.isChatRoom) {
                if let userInfo = obj.userInfo,
                   let publication = userInfo["publication"] as? Message_MessageObjectResponse {
                    if publication.groupType == "peer" {
                        self.didReceiveMessage(userInfo: obj.userInfo)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Notification), perform: { (obj) in
            if UserDefaults.standard.bool(forKey: Constants.isChatRoom) {
                if let userInfo = obj.userInfo,
                   let publication = userInfo["publication"] as? Notification_NotifyObjectResponse {
                    if publication.notifyType == "peer-update-key" {
                        self.viewModel.requestBundleRecipient(byClientId: self.clientId){}
                    }
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
            if UserDefaults.standard.bool(forKey: Constants.isChatRoom) {
                self.getMessageInRoom()
                if let userInfo = obj.userInfo , let isNetWork = userInfo["net_work"] as? Bool {
                    if isNetWork {
                        self.viewModel.requestBundleRecipient(byClientId: self.clientId){}
                    }
                }
            }
        })
    }
}

extension MessageChatView {
    
    func customeNavigationBarView() -> some View {
        VStack {
            Spacer()
            HStack {
                HStack(spacing: 8) {
                    Image("ic_back")
                        .frame(width: 24, height: 24, alignment: .leading)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                        .onTapGesture {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    
                    ChannelUserAvatar(avatarSize: 36, text: .constant(userName))
                    
                    Text(self.userName)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                        .font(AppTheme.fonts.textLarge.font)
                        .fontWeight(.medium)
                }
                Spacer()
                HStack{
                    Button(action: {
                        call(callType: .audio)
                    }, label: {
                        Image("ic_call")
                            .frame(width: 36, height: 36)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                            .padding(.trailing, 20)
                    })
                    Button(action: {
                        call(callType: .video)
                    }, label: {
                        Image("ic_video_call")
                            .frame(width: 36, height: 36)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                    })
                }
            }
            .padding()
        }
        .applyNavigationBarStyle()
    }
    
    func sendMessageBarView() -> some View {
        HStack(spacing: 15) {
            
            Button {} label: {
                Image("ic_photo")
                    .foregroundColor(AppTheme.colors.gray1.color)
            }
            
            Button {} label: {
                Image("ic_tag")
                    .foregroundColor(AppTheme.colors.gray1.color)
            }
            
            
            HStack(spacing: 15){
                MultilineTextField("Type Something Here", text: $messageStr)
            }
            .padding(.vertical, 4)
            .padding(.horizontal)
            .background(AppTheme.colors.gray5.color)
            .cornerRadius(16)
            .clipped()
            
            
            // Send Button...
            // hiding view...
            //                if messageStr != ""{
            Button(action: {
                // appeding message...
                // adding animation...
                withAnimation(.easeIn){
                    self.send()
                }
                messageStr = ""
            }, label: {
                Image("ic_sent")
                    .foregroundColor(AppTheme.colors.primary.color)
            })
            //                }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .animation(.easeOut)
    }
    
    func messageListView() -> some View {
        Group {
            if #available(iOS 14.0, *) {
                GeometryReader { geoReader in
                    ScrollView(.vertical, showsIndicators: false, content: {
                        HStack { Spacer() }
                        ScrollViewReader{reader in
                            LazyVStack(spacing: 16){
                                let messages = realmMessages.allMessageInGroup(groupId: self.myGroupID)
                                let lst = CKExtensions.getMessageAndSection(messages)
                                ForEach(lst , id: \.title) { gr in
                                    Section(header: Text(gr.title)
                                                .font(AppTheme.fonts.textSmall.font)
                                                .foregroundColor(AppTheme.colors.gray3.color)) {
                                        let listDisplayMessage = MessageUtils.getListRectCorner(messages: gr.messages)
                                        ForEach(listDisplayMessage , id: \.message.id) { msg in
                                            // Chat Bubbles...
                                            MessageBubble(msg: msg.message, rectCorner: msg.rectCorner)
                                                .id(msg.message.id)
                                        }
                                    }
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
                            .onReceive(NotificationCenter.default.publisher(for: NSNotification.keyBoardWillShow)) { (data) in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    reader.scrollTo(self.getIdLastItem(), anchor: .bottom)
                                }
                            }
                        }
                    })
                    
                }.gesture(
                    TapGesture()
                        .onEnded { _ in
                            UIApplication.shared.endEditing()
                        })
            } else {
                GeometryReader { reader in
                    ScrollView(.vertical, showsIndicators: false, content: {
                        HStack { Spacer() }
                        VStack(spacing: 16){
                            let messages = realmMessages.allMessageInGroup(groupId: self.myGroupID)
                            let lst = CKExtensions.getMessageAndSection(messages)
                            ForEach(lst , id: \.title) { gr in
                                Section(header: Text(gr.title)
                                            .font(AppTheme.fonts.textSmall.font)
                                            .foregroundColor(AppTheme.colors.gray3.color)) {
                                    let listDisplayMessage = MessageUtils.getListRectCorner(messages: gr.messages)
                                    ForEach(listDisplayMessage , id: \.message.id) { msg in
                                        // Chat Bubbles...
                                        MessageBubble(msg: msg.message, rectCorner: msg.rectCorner)
                                            .id(msg.message.id)
                                    }
                                }
                            }
                        }
                        .onAppear(perform: {
                            self.scrollingProxy = ListScrollingProxy()
                            self.reloadData()
                        })
                        .padding([.horizontal,.bottom])
                        .padding(.top, 25)
                    })
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.keyBoardWillShow)) { (data) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.scrollingProxy.scrollTo(.end)
                        }
                    }
                }.gesture(
                    TapGesture()
                        .onEnded { _ in
                            UIApplication.shared.endEditing()
                        })
            }
        }
    }
}

extension MessageChatView {
    
    func call(callType type: Constants.CallType) {
        AVCaptureDevice.authorizeVideo(completion: { (status) in
            AVCaptureDevice.authorizeAudio(completion: { (status) in
                if status == .alreadyAuthorized || status == .justAuthorized {
                    hudVisible = true
                    // CallManager call
                    if let group = groupRealms.getGroup(clientId: clientId, type: groupType) {
                        viewModel.callPeerToPeer(group: group, clientId: clientId, callType: type) {
                            hudVisible = false
                        }
                    } else {
                        viewModel.createGroup(username: self.userName, clientId: self.clientId) { (group) in
                            viewModel.callPeerToPeer(group: group, clientId: clientId, callType: type) {
                                hudVisible = false
                            }
                        }
                    }
                } else {
                    self.alertVisible = true
                }
            })
        })
    }
    
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
                                                    fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
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
                                                    fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
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
        if self.groupId != 0 {
            Backend.shared.getMessageInRoom(self.groupId,
                                            self.groupRealms.getTimeSyncInGroup(groupID: self.groupId)) { (result, error) in
                if let result = result {
                    if !result.lstMessage.isEmpty {
                        DispatchQueue.main.async {
                            self.groupRealms.updateTimeSyncMessageInGroup(groupID: self.groupId, lastMessageAt: result.lstMessage.last?.createdAt ?? 0)
                        }
                    }
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
                                                                fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: message.fromClientID, groupID: message.groupID),
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
            self.messages = realmMessages.allMessageInGroup(groupId: self.myGroupID)
            self.scrollingProxy.scrollTo(.end)
        }
    }
    
    
    private func send() {
        if messageStr.trimmingCharacters(in: .whitespaces).isEmpty {return}
        self.sendMessage(messageStr: $messageStr.wrappedValue)
    }
    
    func sendMessage(messageStr: String) {
        
        if messageStr.trimmingCharacters(in: .whitespaces).isEmpty {
            return
        }
        
        
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        //        self.viewModel.requestBundleRecipient(byClientId: clientId) {
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
                                                            fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: result.fromClientID, groupID: result.groupID),
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
                                                        fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: result.fromClientID, groupID: result.groupID),
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
        //        }
        self.reloadData()
    }
}

/*
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
 */
