//
//  MessagerView.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/24/21.
//

import SwiftUI
import AVFoundation
import Introspect

struct MessagerView: View {
    // MARK: - EnvironmentObject
    @EnvironmentObject var viewRouter: ViewRouter
    
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // MARK: - ObservedObject
    @ObservedObject var viewModel: MessengerViewModel = MessengerViewModel()
    
    // MARK: - State
    @State private var hudVisible = false
    @State private var alertVisible = false
    @State private var scrollView: UIScrollView?
    
    // MARK: - Variables
    
    // MARK: - Init
    private init() {
    }
    
    init(clientId: String, groupId: Int64, userName: String) {
        self.init()
        viewModel.setup(receiveId: clientId, groupId: groupId, username: userName, groupType: "peer")
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false, content: {
                HStack { Spacer() }
                if #available(iOS 14.0, *) {
                    ScrollViewReader{ reader in
                        MessagerListView(messages: viewModel.messages) { msg in
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
                    MessagerListView(messages: viewModel.messages) { msg in
                        // Chat Bubbles...
                        MessageBubble(msg: msg.message, isGroup: viewModel.isGroup, isShowAvatarAndUserName: msg.showAvatarAndUserName, rectCorner: msg.rectCorner)
                            .id(msg.message.id)
                    }
                    .introspectScrollView { scrollView in
                        scrollView.scrollToBottom(animated: false)
                        self.scrollView = scrollView
                    }
                    .onAppear(perform: {
                        self.scrollView?.scrollToBottom()
                    })
                    .onReceive(NotificationCenter.default.publisher(for: NSNotification.keyBoardWillShow)) { (data) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.scrollView?.scrollToBottom()
                        }
                    }
                }
            })
            
            MessagerToolBar(sendAction: { message in
                self.viewModel.sendMessage(messageStr: message) {
                    self.scrollView?.scrollToBottom()
                }
            })
            
        }
        .applyNavigationBarChatStyle(titleView: {
            createTitleView()
        }, invokeBackButton: {
            self.presentationMode.wrappedValue.dismiss()
        }, invokeCallButton: { callType in
            call(callType: callType)
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
        .onAppear() {
            ChatService.shared.setOpenedGroupId(viewModel.groupId)
            UserDefaults.standard.setValue(viewModel.groupId, forKey: Constants.openGroupId)
            UserDefaults.standard.setValue(true, forKey: Constants.isInChatRoom)
            
            self.viewModel.getMessageInRoom(completion: {
                self.scrollView?.scrollToBottom()
            })
        }
        .onDisappear(){
            ChatService.shared.setOpenedGroupId(-1)
            UserDefaults.standard.setValue(-1, forKey: Constants.openGroupId)
            UserDefaults.standard.setValue(false, forKey: Constants.isInChatRoom)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage)) { (obj) in
            if let userInfo = obj.userInfo,
               let message = userInfo["message"] as? MessageModel {
                if message.groupID == ChatService.shared.openedGroupId {
                    self.viewModel.reloadData()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Notification), perform: { (obj) in
            if let userInfo = obj.userInfo,
               let publication = userInfo["publication"] as? Notification_NotifyObjectResponse {
                if publication.notifyType == "peer-update-key" {
                    ChatService.shared.requestKeyPeer(byClientId: viewModel.receiveId, completion: { _ in })
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
            self.viewModel.getMessageInRoom(completion: {
                self.scrollView?.scrollToBottom()
            })
            if let userInfo = obj.userInfo , let isNetWork = userInfo["net_work"] as? Bool {
                if isNetWork {
                    ChatService.shared.requestKeyPeer(byClientId: viewModel.receiveId, completion: { _ in })
                }
            }
        })
    }
    
    private func createTitleView() -> some View {
        HStack {
            ChannelUserAvatar(avatarSize: 36, text: viewModel.username)
            
            Text(viewModel.username)
                .foregroundColor(AppTheme.colors.offWhite.color)
                .font(AppTheme.fonts.textLarge.font)
                .fontWeight(.medium)
                .lineLimit(2)
        }
    }
}

extension MessagerView {
    func call(callType type: Constants.CallType) {
        AVCaptureDevice.authorizeVideo(completion: { (status) in
            AVCaptureDevice.authorizeAudio(completion: { (status) in
                if status == .alreadyAuthorized || status == .justAuthorized {
                    hudVisible = true
                    // CallManager call
                    viewModel.callPeerToPeer(clientId: viewModel.receiveId, callType: type) {
                        hudVisible = false
                    }
                } else {
                    self.alertVisible = true
                }
            })
        })
    }
}
