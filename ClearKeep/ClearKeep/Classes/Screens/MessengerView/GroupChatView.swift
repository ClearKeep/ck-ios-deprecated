//
//  GroupChatView.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/17/21.
//

import SwiftUI
import AVFoundation
import Introspect

struct GroupChatView: View {
    // MARK: - EnvironmentObject
    @EnvironmentObject var viewRouter: ViewRouter
    
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.rootPresentationMode) var rootPresentationMode: Binding<RootPresentationMode>
    
    // MARK: - State
    @State private var hudVisible = false
    @State private var alertVisible = false
    @State private var messageStr = ""
    @State private var scrollView: UIScrollView?
    
    @ObservedObject var viewModel: MessageChatViewModel = MessageChatViewModel()
    
    // MARK: - Variables
    private var userName: String = ""
    private var groupName: String = ""
    private var groupType: String = "peer"
    private var clientId: String = ""
    private var groupId: Int64 = 0
    private var isCreateGroup: Bool = false
    // MARK: - Init
    private init() {
    }
    
    init(userName: String, clientId: String) {
        self.init()
        self.userName = userName
        self.clientId = clientId
        self.groupType = "peer"
        self.viewModel.setup(clientId: clientId, username: userName, groupType: groupType)
    }
    
    init(groupName: String, groupId: Int64, isCreateGroup: Bool = false) {
        self.init()
        self.groupName = groupName
        self.groupType = "group"
        self.groupId = groupId
        self.isCreateGroup = isCreateGroup
        self.viewModel.setup(groupId: groupId, groupType: groupType)
    }
    
    // MARK: - Setting views
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false, content: {
                HStack { Spacer() }
                if #available(iOS 14.0, *) {
                    ScrollViewReader{ reader in
                        MessageListView(messages: viewModel.messages) { msg in
                            // Chat Bubbles...
                            MessageBubble(msg: msg.message, isGroup: viewModel.isGroup, isShowAvatarAndUserName: msg.showAvatarAndUserName, rectCorner: msg.rectCorner)
                                .id(msg.message.id)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            reader.scrollTo(self.viewModel.getIdLastItem(), anchor: .bottom)
                        }
                        .onAppear(perform: {
                            reader.scrollTo(self.viewModel.getIdLastItem(), anchor: .bottom)
                        })
                        .onReceive(NotificationCenter.default.publisher(for: NSNotification.keyBoardWillShow)) { (data) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                reader.scrollTo(self.viewModel.getIdLastItem(), anchor: .bottom)
                            }
                        }
                    }
                } else {
                    MessageListView(messages: viewModel.messages) { msg in
                        // Chat Bubbles...
                        MessageBubble(msg: msg.message, isGroup: viewModel.isGroup, isShowAvatarAndUserName: msg.showAvatarAndUserName, rectCorner: msg.rectCorner)
                            .id(msg.message.id)
                    }
                    .introspectScrollView { scrollView in
                        scrollView.scrollToBottom(animated: false)
                        self.scrollView = scrollView
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.keyBoardWillShow)) { (data) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.scrollView?.scrollToBottom()
                        }
                    }
                }
            })
            
            MessageToolBar(sendAction: { message in
                sendMessage(messageStr: message)
            })
            
        }
        .applyNavigationBarChatStyle(titleView: {
            createTitleView()
        }, invokeBackButton: {
            if isCreateGroup {
                self.viewRouter.current = .tabview
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }, invokeCallButton: { callType in
            call(callType: callType)
        })
        .onAppear() {
            if viewModel.isGroup {
                UserDefaults.standard.setValue(true, forKey: Constants.isChatGroup)
//                self.viewModel.registerWithGroup()
                DispatchQueue.main.async {
                    RealmManager.shared.realmMessages.loadSavedData()
                    RealmManager.shared.realmGroups.loadSavedData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.viewModel.registerWithGroup()
                        self.viewModel.getMessageInRoom {
                            self.scrollView?.scrollToBottom()
                        }
                    }
                }
            } else {
                UserDefaults.standard.setValue(true, forKey: Constants.isChatRoom)
                self.viewModel.requestBundleRecipient(byClientId: clientId){}
                DispatchQueue.main.async {
                    RealmManager.shared.realmMessages.loadSavedData()
                    RealmManager.shared.realmGroups.loadSavedData()
                }
                self.viewModel.getMessageInRoom {
                    self.scrollView?.scrollToBottom()
                }
            }
        }
        .onDisappear(){
            if viewModel.isGroup {
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
                        didReceiveMessage(publication: publication)
                    }
                }
                if publication.groupType == "peer" {
                    if let clientId = userInfo["clientId"] as? String,
                       clientId == self.clientId,
                       !viewModel.isExistMessage(msgId: publication.id) {
                        didReceiveMessage(publication: publication)
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
            self.viewModel.getMessageInRoom {
                self.scrollView?.scrollToBottom()
            }
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
    
    private func createTitleView() -> some View {
        Group {
            if viewModel.isGroup {
                NavigationLink(
                    destination: GroupChatDetailView(groupModel: viewModel.getGroupModel()),
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

// MARK: - Private function
extension GroupChatView {
    private func call(callType type: Constants.CallType) {
        AVCaptureDevice.authorizeVideo(completion: { (status) in
            AVCaptureDevice.authorizeAudio(completion: { (status) in
                if status == .alreadyAuthorized || status == .justAuthorized {
                    hudVisible = true
                    if viewModel.isGroup {
                        // CallManager call
                        viewModel.callGroup(groupId: viewModel.groupId, callType: type) {
                            hudVisible = false
                        }
                    } else {
                        if viewModel.isExistedGroup() {
                            viewModel.callPeerToPeer(groupId: viewModel.groupId, clientId: clientId, callType: type) {
                                hudVisible = false
                            }
                        } else {
                            viewModel.createGroup(username: userName, clientId: clientId) { (group) in
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
    
    private func didReceiveMessage(publication: Message_MessageObjectResponse) {
        self.viewModel.decryptionMessage(publication: publication, completion: { messageModel in
            self.scrollView?.scrollToBottom()
        })
    }
    
    private func sendMessage(messageStr: String) {
        func handleSentMessage(messageModel: MessageModel) {
            self.scrollView?.scrollToBottom()
        }
        
        let messageStr = messageStr.trimmingCharacters(in: .whitespacesAndNewlines)
        if messageStr.isEmpty {
            return
        }
        
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            if viewModel.isExistedGroup() {
                viewModel.sendMessage(payload: payload, fromClientId: myAccount.username) { messageModel in
                    DispatchQueue.main.async {
                        handleSentMessage(messageModel: messageModel)
                    }
                }
            } else {
                viewModel.createGroup(username: userName, clientId: clientId) { (group) in
                    viewModel.sendMessage(payload: payload, fromClientId: myAccount.username) { messageModel in
                        DispatchQueue.main.async {
                            handleSentMessage(messageModel: messageModel)
                        }
                    }
                }
            }
        }
    }
}
