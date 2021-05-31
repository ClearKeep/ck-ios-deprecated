//
//  MessagerGroupView.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/25/21.
//

import SwiftUI
import Introspect
import AVFoundation

struct MessagerGroupView: View {
    // MARK: - EnvironmentObject
    @EnvironmentObject var viewRouter: ViewRouter
    
    // MARK: - Environment
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    // MARK: - ObservedObject
    @ObservedObject var viewModel: MessengerViewModel = MessengerViewModel()
    
    // MARK: - State
    @State private var hudVisible = false
    @State private var alertVisible = false
    @State private var scrollView: UIScrollView?
    @State private var navigationController: UINavigationController?
    
    // MARK: - Variables
    private var userName: String = ""
    private var groupName: String = ""
    private var clientId: String = ""
    private var groupId: Int64 = 0
    private var isCreateGroup: Bool = false
    
    // MARK: - Init
    private init() {
    }
    
    init(groupName: String, groupId: Int64, isCreateGroup: Bool = false) {
        self.init()
        self.groupName = groupName
        self.groupId = groupId
        self.isCreateGroup = isCreateGroup
        self.viewModel.setup(groupId: groupId, username: groupName, groupType: "group")
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
                self.viewModel.sendMessage(messageStr: message)
            })
            
        }
        .introspectNavigationController(customize: { navigationController in
            self.navigationController = navigationController
        })
        .applyNavigationBarChatStyle(titleView: {
            createTitleView()
        }, invokeBackButton: {
            if self.isCreateGroup {
                self.navigationController?.popToRootViewController(animated: true)
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
            ChatService.shared.setOpenedGroupId(groupId)
            UserDefaults.standard.setValue(groupId, forKey: Constants.openGroupId)
            UserDefaults.standard.setValue(true, forKey: Constants.isInChatRoom)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.viewModel.getMessageInRoom(completion: {
                    self.scrollView?.scrollToBottom()
                })
            }
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
            self.viewModel.getMessageInRoom(completion: {
                self.scrollView?.scrollToBottom()
            })
        })
    }
    
    private func createTitleView() -> some View {
        NavigationLink(
            destination: GroupChatDetailView(groupModel: viewModel.getGroupModel()),
            label: {
                Text(groupName)
                    .foregroundColor(AppTheme.colors.offWhite.color)
                    .font(AppTheme.fonts.textLarge.font)
                    .fontWeight(.medium)
                    .lineLimit(2)
            })
    }
}

extension MessagerGroupView {
    func call(callType type: Constants.CallType) {
        AVCaptureDevice.authorizeVideo(completion: { (status) in
            AVCaptureDevice.authorizeAudio(completion: { (status) in
                if status == .alreadyAuthorized || status == .justAuthorized {
                    hudVisible = true
                    // CallManager call
                    viewModel.callGroup(callType: type) {
                        hudVisible = false
                    }
                } else {
                    self.alertVisible = true
                }
            })
        })
    }
}
