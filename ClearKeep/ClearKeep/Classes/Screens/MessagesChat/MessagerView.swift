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
    
    @State private var showingAlbumsSheet = false
    @State private var showAlbumsView = false
    
    // MARK: - Variables
    private var isFromPeopleList: Bool = false
    
    // MARK: - Init
    private init() {
    }
    
    init(clientId: String, groupId: Int64, userName: String, workspace_domain: String, isFromPeopleList: Bool = false) {
        self.init()
        self.isFromPeopleList = isFromPeopleList
        viewModel.setup(receiveId: clientId, groupId: groupId, username: userName, workspace_domain: workspace_domain, groupType: "peer")
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
                }
            })
            .onTapGesture {
                self.hideKeyboard()
            }
            
            MessagerToolBar(sendAction: { message in
                self.viewModel.sendMessage(messageStr: message) {
                    self.scrollView?.scrollToBottom()
                }
            }, sharePhoto: {
                self.showingAlbumsSheet = true
            })
            
        }
        .applyNavigationBarChatStyle(titleView: {
            createTitleView()
        }, invokeBackButton: { navigationController in
            if isFromPeopleList {
                navigationController?.popToRootViewController(animated: true)
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }, invokeCallButton: { callType in
            call(callType: callType)
        })
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
        .actionSheet(isPresented: $showingAlbumsSheet, content: {
            ActionSheet(title: Text("Take a photo"),
                        buttons: [ .default(Text("Albums")) {
                            self.showAlbumsView = true
                        },
                        .cancel()
                        ])
        })
        .compatibleFullScreen(isPresented: showAlbumsView) {
            AlbumsView(dismissAlert: $showAlbumsView)
        }
        .onAppear() {
            ChatService.shared.setOpenedGroupId(viewModel.groupId)
            self.viewModel.reloadData()
            self.viewModel.getMessageInRoom(completion: {
                self.scrollView?.scrollToBottom()
            })
        }
        .onDisappear(){
            ChatService.shared.setOpenedGroupId(-1)
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
                    ChatService.shared.requestKeyPeer(byClientId: viewModel.receiveId, workspaceDomain: viewModel.workspace_domain, completion: { _ in })
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
            self.viewModel.getMessageInRoom(completion: {
                self.scrollView?.scrollToBottom()
            })
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

struct MessagerView_Provider: PreviewProvider {
    static var previews: some View {
        MessagerView(clientId: "fdsfs", groupId: 123, userName: "test", workspace_domain: "54.235.68.160:25000")
    }
}
