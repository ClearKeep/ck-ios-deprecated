//
//  GroupChatView.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/17/21.
//

import SwiftUI
import AVFoundation

struct GroupChatView: View {
    // MARK: - Variables
    @EnvironmentObject var realmGroups : RealmGroups
    @EnvironmentObject var realmMessages : RealmMessages
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.rootPresentationMode) var rootPresentationMode: Binding<RootPresentationMode>
    
    @State private var hudVisible = false
    @State private var alertVisible = false
    @State private var messageStr = ""
    @State private var messages = [MessageModel]()
    
    @ObservedObject var viewModel: MessageChatViewModel = MessageChatViewModel()
    
    private let scrollingProxy = ListScrollingProxy()
    
    private var userName: String = ""
    private var groupName: String = ""
    private var groupType: String = "peer"
    private var clientId: String = ""
    private var groupId: Int64 = 0
    
    private init() {
    }
    
    init(userName: String, clientId: String, groupId: Int64 = 0) {
        self.init()
        self.userName = userName
        self.clientId = clientId
        self.groupType = "peer"
        self.groupId = groupId
        self.viewModel.setup(clientId: clientId, username: userName, groupId: groupId, groupType: groupType)
    }
    
    init(groupName: String, groupId: Int64) {
        self.init()
        self.groupName = groupName
        self.groupType = "group"
        self.groupId = groupId
        self.viewModel.setup(groupId: groupId, groupType: groupType)
    }
    
    // MARK: - Setting views
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false, content: {
                HStack { Spacer() }
                if #available(iOS 14.0, *) {
                    ScrollViewReader{ reader in
                        let messages = realmMessages.allMessageInGroup(groupId: viewModel.groupId)
                        MessageListView(messages: messages) { msg in
                            // Chat Bubbles...
                            MessageBubble(msg: msg.message, isGroup: isGroup(), isShowAvatarAndUserName: msg.showAvatarAndUserName, rectCorner: msg.rectCorner)
                                .id(msg.message.id)
                        }
                        .onChange(of: realmMessages.allMessageInGroup(groupId: groupId).count) { _ in
                            reader.scrollTo(self.getIdLastItem(), anchor: .bottom)
                        }
                        .onAppear(perform: {
                            reader.scrollTo(self.getIdLastItem(), anchor: .bottom)
                        })
                        .onReceive(NotificationCenter.default.publisher(for: NSNotification.keyBoardWillShow)) { (data) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                reader.scrollTo(self.getIdLastItem(), anchor: .bottom)
                            }
                        }
                    }
                } else {
                    let messages = realmMessages.allMessageInGroup(groupId: viewModel.groupId)
                    MessageListView(messages: messages) { msg in
                        // Chat Bubbles...
                        MessageBubble(msg: msg.message, isGroup: isGroup(), isShowAvatarAndUserName: msg.showAvatarAndUserName, rectCorner: msg.rectCorner)
                            .id(msg.message.id)
                            .background(
                                ListScrollingHelper(proxy: self.scrollingProxy)
                            )
                    }
                    .onAppear(perform: {
                        self.scrollingProxy.scrollTo(.end)
                    })
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.keyBoardWillShow)) { (data) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.scrollingProxy.scrollTo(.end)
                        }
                    }
                }
            })
            
            HStack(spacing: 15) {
                Button {} label: {
                    Image("ic_photo")
                        .foregroundColor(AppTheme.colors.gray1.color)
                }
                Button {} label: {
                    Image("ic_tag")
                        .foregroundColor(AppTheme.colors.gray1.color)
                }
                
                MultilineTextField("Type Something Here", text: $messageStr)
                    .padding(.vertical, 4)
                    .padding(.horizontal)
                    .background(AppTheme.colors.gray5.color)
                    .cornerRadius(16)
                    .clipped()
                
                // Send Button...
                Button(action: {
                    // appeding message...
                    // adding animation...
                    withAnimation(.easeIn){
                        self.sendMessage(messageStr: messageStr)
                    }
                    messageStr = ""
                }, label: {
                    Image("ic_sent")
                        .foregroundColor(AppTheme.colors.primary.color)
                })
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .animation(.easeOut)
        }
        .applyNavigationBarChatStyle(titleView: {
            createTitleView()
        }, invokeBackButton: {
            self.presentationMode.wrappedValue.dismiss()
        }, invokeCallButton: { callType in
            call(callType: callType)
        })
        .onAppear() {
            DispatchQueue.main.async {
                self.realmMessages.loadSavedData()
                self.realmGroups.loadSavedData()
            }
            
            if isGroup() {
                UserDefaults.standard.setValue(true, forKey: Constants.isChatGroup)
                self.registerWithGroup(groupId)
            } else {
                UserDefaults.standard.setValue(true, forKey: Constants.isChatRoom)
                if viewModel.groupId == 0, let group = realmGroups.getGroup(clientId: clientId, type: groupType) {
                    viewModel.groupId = group.groupID
                }
                self.viewModel.requestBundleRecipient(byClientId: clientId){}
            }
            self.getMessageInRoom()
        }
        .onDisappear(){
            if isGroup() {
                UserDefaults.standard.setValue(false, forKey: Constants.isChatGroup)
            } else {
                UserDefaults.standard.setValue(false, forKey: Constants.isChatRoom)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage)) { (obj) in
            if let userInfo = obj.userInfo,
               let publication = userInfo["publication"] as? Message_MessageObjectResponse {
                if publication.groupType == "group"{
                    if UserDefaults.standard.bool(forKey: Constants.isChatGroup){
                        self.viewModel.isForceProcessKey = true
                        self.didReceiveMessage(publication: publication)
                    }
                }
                if publication.groupType == "peer" {
                    if let clientId = userInfo["clientId"] as? String,
                       clientId == self.clientId,
                       !realmMessages.isExistMessage(msgId: publication.id) {
                        self.didReceiveMessage(publication: publication)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
            self.getMessageInRoom()
        })
        .keyboardManagment()
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .onTapGesture {
            self.hideKeyboard()
        }
        .alert(isPresented: $alertVisible, content: {
            Alert (title: Text("Need camera and microphone permissions"),
                   message: Text("Go to Settings?"),
                   primaryButton: .default(Text("Settings"), action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                   }),
                   secondaryButton: .default(Text("Cancel")))
        })
    }
}

extension GroupChatView {
    private func isGroup() -> Bool {
        return groupType == "group" ? true : false
    }
    
    func call(callType type: Constants.CallType) {
        AVCaptureDevice.authorizeVideo(completion: { (status) in
            AVCaptureDevice.authorizeAudio(completion: { (status) in
                if status == .alreadyAuthorized || status == .justAuthorized {
                    hudVisible = true
                    if isGroup() {
                        // CallManager call
                        viewModel.callGroup(groupId: viewModel.groupId, callType: type) {
                            hudVisible = false
                        }
                    } else {
                        if let group = realmGroups.getGroup(clientId: clientId, type: groupType) {
                            viewModel.groupId = group.groupID
                            viewModel.callPeerToPeer(groupId: group.groupID, clientId: clientId, callType: type) {
                                hudVisible = false
                            }
                        } else {
                            viewModel.createGroup(username: userName, clientId: clientId) { (group) in
                                realmGroups.add(group: group)
                                viewModel.callPeerToPeer(groupId: group.groupID, clientId: clientId, callType: type) {
                                    hudVisible = false
                                }
                            }
                        }
                    }
                } else {
                    self.alertVisible = true
                }
            })
        })
    }
    
    private func getIdLastItem() -> String {
        let msgInRoom = realmMessages.allMessageInGroup(groupId: viewModel.groupId)
        var id = ""
        if msgInRoom.count > 0 {
            id = msgInRoom[msgInRoom.count - 1].id
        }
        return id
    }
    
    private func didReceiveMessage(publication: Message_MessageObjectResponse) {
        self.viewModel.decryptionMessage(publication: publication, completion: { messageModel in
            let fromDisplayName = realmGroups.getDisplayNameSenderMessage(fromClientId: messageModel.fromClientID, groupID: messageModel.groupID)
            var message = messageModel
            message.fromDisplayName = fromDisplayName
            self.realmMessages.add(message: message)
            self.realmGroups.updateLastMessage(groupID: message.groupID, lastMessage: message.message, lastMessageAt: message.createdAt, idLastMessage: message.id)
            self.reloadData()
            self.scrollingProxy.scrollTo(.end)
        })
    }
    
    private func registerWithGroup(_ groupId: Int64) {
        if let group = self.realmGroups.filterGroup(groupId: groupId) {
            if !group.isRegister {
                if let myAccount = CKSignalCoordinate.shared.myAccount , let ourAccountEncryptMng = self.viewModel.ourEncryptionManager {
                    let userName = myAccount.username
                    let deviceID = Int32(555)
                    let address = SignalAddress(name: userName, deviceId: deviceID)
                    let groupSessionBuilder = SignalGroupSessionBuilder(context: ourAccountEncryptMng.signalContext)
                    let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
                    
                    do {
                        let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
                        Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                                   clientId: userName,
                                                                   deviceId: deviceID,
                                                                   senderKeyData: signalSKDM.serializedData()) { (result, error) in
                            print("Register group with result: \(result)")
                            if result {
                                self.realmGroups.registerGroup(groupId: groupId)
                            }
                        }
                        
                    } catch {
                        print("Register group error: \(error)")
                        
                    }
                }
            }
        }
    }
    
    private func getMessageInRoom() {
        if viewModel.groupId != 0 {
            Backend.shared.getMessageInRoom(viewModel.groupId,
                                            self.realmGroups.getTimeSyncInGroup(groupID: viewModel.groupId)) { (result, error) in
                if let result = result {
                    if !result.lstMessage.isEmpty {
                        DispatchQueue.main.async {
                            let listMsgSorted = result.lstMessage.sorted { (msg1, msg2) -> Bool in
                                return msg1.createdAt > msg2.createdAt
                            }
                            self.realmGroups.updateTimeSyncMessageInGroup(groupID: viewModel.groupId, lastMessageAt: listMsgSorted[0].createdAt)
                        }
                    }
                    result.lstMessage.forEach { (message) in
                        let filterMessage = self.realmMessages.allMessageInGroup(groupId: message.groupID).filter{$0.id == message.id}
                        if filterMessage.isEmpty {
                            if let ourEncryptionMng = self.viewModel.ourEncryptionManager {
                                do {
                                    let decryptedData = try ourEncryptionMng.decryptFromAddress(message.message,
                                                                                                name: clientId,
                                                                                                deviceId: UInt32(555))
                                    let messageDecryption = String(data: decryptedData, encoding: .utf8)
                                    print("Message decryption: \(messageDecryption ?? "Empty error")")
                                    
                                    DispatchQueue.main.async {
                                        let post = MessageModel(id: message.id,
                                                                groupID: message.groupID,
                                                                groupType: message.groupType,
                                                                fromClientID: message.fromClientID,
                                                                fromDisplayName: self.realmGroups.getDisplayNameSenderMessage(fromClientId: message.fromClientID, groupID: message.groupID),
                                                                clientID: message.clientID,
                                                                message: decryptedData,
                                                                createdAt: message.createdAt,
                                                                updatedAt: message.updatedAt)
                                        self.realmMessages.add(message: post)
                                        self.viewModel.groupId = message.groupID
                                        self.realmGroups.updateLastMessage(groupID: message.groupID, lastMessage: decryptedData, lastMessageAt: message.createdAt, idLastMessage: message.id)
                                        self.reloadData()
                                        self.scrollingProxy.scrollTo(.end)
                                    }
                                } catch {
                                    print("Decryption message error: \(error)")
                                }
                            }
                        }
                    }
                    self.reloadData()
                    self.scrollingProxy.scrollTo(.end)
                }
            }
        }
    }
    
    private func reloadData(){
        DispatchQueue.main.async {
            self.realmMessages.loadSavedData()
            self.messages = realmMessages.allMessageInGroup(groupId: viewModel.groupId)
        }
    }
    
    private func sendMessage(messageStr: String) {
        func handleSentMessage(messageModel: MessageModel) {
            let fromDisplayName = realmGroups.getDisplayNameSenderMessage(fromClientId: messageModel.fromClientID, groupID: messageModel.groupID)
            var message = messageModel
            message.fromDisplayName = fromDisplayName
            self.realmMessages.add(message: messageModel)
            self.realmGroups.updateLastMessage(groupID: messageModel.groupID,
                                               lastMessage: messageModel.message,
                                               lastMessageAt: messageModel.createdAt,
                                               idLastMessage: messageModel.id)
            self.reloadData()
            self.scrollingProxy.scrollTo(.end)
        }
        
        if messageStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            if viewModel.groupId == 0, let group = realmGroups.getGroup(clientId: clientId) {
                viewModel.groupId = group.groupID
            }
            if viewModel.groupId == 0 {
                viewModel.createGroup(username: userName, clientId: clientId) { (group) in
                    realmGroups.add(group: group)
                    viewModel.sendMessage(payload: payload, fromClientId: myAccount.username, toClientId: clientId, groupType: groupType) { messageModel in
                        DispatchQueue.main.async {
                            handleSentMessage(messageModel: messageModel)
                        }
                    }
                }
            } else {
                viewModel.sendMessage(payload: payload, fromClientId: myAccount.username, toClientId: clientId, groupType: groupType) { messageModel in
                    DispatchQueue.main.async {
                        handleSentMessage(messageModel: messageModel)
                    }
                }
            }
        }
        self.reloadData()
    }
}

// MARK - Private function setupView
extension GroupChatView {
    private func createTitleView() -> some View {
        Group {
            if isGroup() {
                NavigationLink(
                    destination: MotherView(),
                    label: {
                        Text(groupName)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                            .font(AppTheme.fonts.textLarge.font)
                            .fontWeight(.medium)
                            .lineLimit(2)
                    })
            } else {
                HStack {
                    ChannelUserAvatar(avatarSize: 36, text: userName)
                    
                    Text(userName)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                        .font(AppTheme.fonts.textLarge.font)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }
            }
        }
    }
}
