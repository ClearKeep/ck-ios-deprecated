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
    private var userName: String = ""
    private var groupName: String = ""
    private var groupType: String = "peer"
    private var clientId: String = ""
    private var groupId: Int64 = 0
    private var isCreateGroup: Bool = false
    // MARK: - Init
    private init() {
    }
    
    init(clientId: String, groupId: Int64, userName: String, groupType: String = "peer") {
        self.init()
        self.userName = userName
        self.clientId = clientId
        self.groupType = groupType
        if groupId == 0, let group = RealmManager.shared.realmGroups.getGroup(clientId: clientId, type: groupType) {
            self.groupId = group.groupID
        } else {
            self.groupId = groupId
        }
        viewModel.setup(clientId: clientId, groupId: self.groupId, username: userName, groupType: groupType)
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
            if isCreateGroup {
                self.viewRouter.current = .tabview
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
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
            UserDefaults.standard.setValue(groupId, forKey: Constants.openGroupId)
            
            self.viewModel.requestBundleRecipient(byClientId: self.clientId){}
            DispatchQueue.main.async {
                RealmManager.shared.realmMessages.loadSavedData()
                RealmManager.shared.realmGroups.loadSavedData()
            }
            self.viewModel.getMessageInRoom(completion: {
                self.scrollView?.scrollToBottom()
            })
        }
        .onDisappear(){
            UserDefaults.standard.setValue(-1, forKey: Constants.openGroupId)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage)) { (obj) in
            if let userInfo = obj.userInfo,
               let publication = userInfo["publication"] as? Message_MessageObjectResponse {
                if publication.groupType == "peer" && groupId == publication.groupID {
                    self.viewModel.didReceiveMessage(userInfo: obj.userInfo, completion: {
                        self.scrollView?.scrollToBottom()
                    })
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Notification), perform: { (obj) in
            if let userInfo = obj.userInfo,
               let publication = userInfo["publication"] as? Notification_NotifyObjectResponse {
                if publication.notifyType == "peer-update-key" {
                    self.viewModel.requestBundleRecipient(byClientId: self.clientId){}
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
            self.viewModel.getMessageInRoom(completion: {
                self.scrollView?.scrollToBottom()
            })
            if let userInfo = obj.userInfo , let isNetWork = userInfo["net_work"] as? Bool {
                if isNetWork {
                    self.viewModel.requestBundleRecipient(byClientId: self.clientId){}
                }
            }
        })
    }
    
    private func createTitleView() -> some View {
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

extension MessagerView {
    func call(callType type: Constants.CallType) {
        AVCaptureDevice.authorizeVideo(completion: { (status) in
            AVCaptureDevice.authorizeAudio(completion: { (status) in
                if status == .alreadyAuthorized || status == .justAuthorized {
                    hudVisible = true
                    // CallManager call
                    if let group = RealmManager.shared.realmGroups.getGroup(clientId: clientId, type: groupType) {
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
}

//struct MessagerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessagerView()
//    }
//}
