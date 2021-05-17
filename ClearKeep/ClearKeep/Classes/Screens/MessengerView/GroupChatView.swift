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
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var realmMessages : RealmMessages
    @EnvironmentObject var viewRouter: ViewRouter
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var hudVisible = false
    @State private var alertVisible = false
    
    @ObservedObject var viewModel: MessageChatViewModel = MessageChatViewModel()
    
    private var groupModel: GroupModel!
    private var ourEncryptionManager: CKAccountSignalEncryptionManager?
    private var isNewCreatedGroup: Bool = false
    
    init(groupModel: GroupModel, isNewCreatedGroup: Bool = false) {
        self.groupModel = groupModel
        self.isNewCreatedGroup = isNewCreatedGroup
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
        
    }
    // MARK: - Setting views
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false, content: {
                HStack { Spacer() }
                if #available(iOS 14.0, *) {
                    ScrollViewReader{ reader in
                        let messages = realmMessages.allMessageInGroup(groupId: groupModel.groupID)
                        MessageListView(messages: messages) { msg in
                            // Chat Bubbles...
                            MessageBubble(msg: msg.message, isGroup: true, isShowAvatarAndUserName: msg.showAvatarAndUserName, rectCorner: msg.rectCorner)
                                .id(msg.message.id)
                        }
                        .onAppear(perform: {
                        })
                        .onReceive(NotificationCenter.default.publisher(for: NSNotification.keyBoardWillShow)) { (data) in
                        }
                    }
                } else {
                    let messages = realmMessages.allMessageInGroup(groupId: groupModel.groupID)
                    MessageListView(messages: messages) { msg in
                        // Chat Bubbles...
                        MessageBubble(msg: msg.message, isGroup: true, isShowAvatarAndUserName: msg.showAvatarAndUserName, rectCorner: msg.rectCorner)
                            .id(msg.message.id)
                    }
                    .onAppear(perform: {
                    })
                }
            })
        }
        .applyNavigationBarChatStyle(titleView: {
            NavigationLink(
                destination: MotherView(),
                label: {
                    Text(groupModel.groupName)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                        .font(AppTheme.fonts.textLarge.font)
                        .fontWeight(.medium)
                        .lineLimit(2)
                })
        }, invokeBackButton: {
            self.presentationMode.wrappedValue.dismiss()
        }, invokeCallButton: { callType in
            call(callType: callType)
        })
        .onAppear() {
            
        }
        .onDisappear(){
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage)) { (obj) in
            
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
            
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

//struct GroupChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupChatView()
//    }
//}

extension GroupChatView {
    func call(callType type: Constants.CallType) {
        AVCaptureDevice.authorizeVideo(completion: { (status) in
            AVCaptureDevice.authorizeAudio(completion: { (status) in
                if status == .alreadyAuthorized || status == .justAuthorized {
                    hudVisible = true
                    // CallManager call
                    viewModel.callGroup(group: groupModel, callType: type) {
                        hudVisible = false
                    }
                } else {
                    self.alertVisible = true
                }
            })
        })
    }
}

struct MessageListView<Content: View>: View {
    
    private var listMessageAndSection: [SectionWithMessage] = []
    private let content: (MessageDisplayInfo) -> Content
    
    init(messages: [MessageModel], @ViewBuilder content:@escaping (MessageDisplayInfo) -> Content) {
        self.content = content
        self.setupList(messages)
    }
    
    // setupList(_:) Converts your array into multi-dimensional array.
    private mutating func setupList(_ messages: [MessageModel]) {
        listMessageAndSection = CKExtensions.getMessageAndSection(messages)
    }
    
    // The Magic goes here
    var body: some View {
        VStack(spacing: 8) {
            ForEach(listMessageAndSection , id: \.title) { gr in
                Section(header: Text(gr.title)
                            .font(AppTheme.fonts.textSmall.font)
                            .foregroundColor(AppTheme.colors.gray3.color)) {
                    let listDisplayMessage = MessageUtils.getListRectCorner(messages: gr.messages)
                    ForEach(listDisplayMessage , id: \.message.id) { msg in
                        content(msg)
                    }
                }
            }
        }
        .padding([.horizontal,.bottom])
        .padding(.top, 25)
    }
}
