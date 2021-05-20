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
    // MARK: - Variables
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.rootPresentationMode) var rootPresentationMode: Binding<RootPresentationMode>
    
    @State private var hudVisible = false
    @State private var alertVisible = false
    @State private var messageStr = ""
    @State private var scrollView: UIScrollView?
    
    @ObservedObject var viewModel: MessageChatViewModel = MessageChatViewModel()
    
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
                if #available(iOS 14.0, *) {
                    ScrollViewReader{ reader in
                        MessageListView(messages: viewModel.messages) { msg in
                            // Chat Bubbles...
                            MessageBubble(msg: msg.message, isGroup: isGroup(), isShowAvatarAndUserName: msg.showAvatarAndUserName, rectCorner: msg.rectCorner)
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
                        MessageBubble(msg: msg.message, isGroup: isGroup(), isShowAvatarAndUserName: msg.showAvatarAndUserName, rectCorner: msg.rectCorner)
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
            if isGroup() {
                UserDefaults.standard.setValue(true, forKey: Constants.isChatGroup)
                self.viewModel.registerWithGroup(groupId)
            } else {
                UserDefaults.standard.setValue(true, forKey: Constants.isChatRoom)
                self.viewModel.requestBundleRecipient(byClientId: clientId){}
            }
            self.viewModel.getMessageInRoom {
                self.reloadData()
                self.scrollView?.scrollToBottom()
            }
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
                        viewModel.isForceProcessKey = true
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
            self.viewModel.getMessageInRoom {
                self.reloadData()
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
            self.reloadData()
            self.scrollView?.scrollToBottom()
        })
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
//            self.realmMessages.loadSavedData()
//            self.messages = realmMessages.allMessageInGroup(groupId: viewModel.groupId)
        }
    }
    
    private func sendMessage(messageStr: String) {
        func handleSentMessage(messageModel: MessageModel) {
            self.reloadData()
            self.scrollView?.scrollToBottom()
        }
        
        if messageStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            if viewModel.isExistedGroup(){
                viewModel.createGroup(username: userName, clientId: clientId) { (group) in
                    viewModel.sendMessage(payload: payload, fromClientId: myAccount.username) { messageModel in
                        DispatchQueue.main.async {
                            handleSentMessage(messageModel: messageModel)
                        }
                    }
                }
            } else {
                viewModel.sendMessage(payload: payload, fromClientId: myAccount.username) { messageModel in
                    DispatchQueue.main.async {
                        handleSentMessage(messageModel: messageModel)
                    }
                }
            }
        }
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
