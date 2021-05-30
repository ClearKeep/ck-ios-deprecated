//
//  ServerMainView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/22/21.
//

import SwiftUI

struct ServerMainView: View {
    
    // MARK: - Environment
    @EnvironmentObject var viewRouter: ViewRouter
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // MARK: - ObservedObject
    @ObservedObject var viewModel: ServerMainViewModel
    
    // MARK: - State
    @State private var searchText: String = ""
    @State private var isGroupChatExpanded: Bool = true
    @State private var isDirectMessageExpanded: Bool = true
    @State private var isShowingPeopleView = false
    
    // MARK: - Binding
    @Binding var messageData: MessagerBannerModifier.MessageData
    @Binding var isShowMessageBanner: Bool
    
    // MARK: - Setup
    var body: some View {
            VStack (spacing: 20) {
                SearchBar(text: $searchText) { (changed) in
                    if changed {
                    } else {
                        //self.searchUser(searchText)
                    }
                }
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(spacing: 20) {
                        Button(action: {}, label: {
                            HStack {
                                Image("Notes")
                                    .resizable()
                                    .foregroundColor(AppTheme.colors.gray1.color)
                                    .frame(width: 18, height: 18, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                Text("Notes")
                                    .font(AppTheme.fonts.linkMedium.font)
                                    .foregroundColor(AppTheme.colors.gray1.color)
                                Spacer()
                            }
                        })
                        
                        ListGroupView(titleSection: "Group Chat", groups: viewModel.groups, createNewGroup: InviteMemberGroup(), detail: { group in
                            MessagerGroupView(groupName: group.groupName, groupId: group.groupID)
                        }, content: { group in
                            HStack {
                                Text(viewModel.getGroupName(group: group))
                                    .font(AppTheme.fonts.linkSmall.font)
                                    .foregroundColor(AppTheme.colors.gray1.color)
                            }
                        })
                        
                        ListGroupView(titleSection: "Dirrect Messages", groups: viewModel.peers, createNewGroup: PeopleView(), detail: { group in
                            MessagerView(clientId: viewModel.getClientIdFriend(listClientID: group.lstClientID.map{$0.id}), groupId: group.groupID, userName: viewModel.getPeerReceiveName(inGroup: group))
                        }, content: { group in
                            HStack {
                                ChannelUserAvatar(avatarSize: 24, statusSize: 8, text: viewModel.getPeerReceiveName(inGroup: group), font: AppTheme.fonts.linkSmall.font, image: nil, status: .none, gradientBackgroundType: .accent)
                                
                                Text(viewModel.getPeerReceiveName(inGroup: group))
                                    .font(AppTheme.fonts.linkSmall.font)
                                    .foregroundColor(AppTheme.colors.gray1.color)
                            }
                        })
                        
                        Spacer()
                    }
                })
        }
        .padding(.bottom, 20)
        .onTapGesture {
            self.hideKeyboard()
        }
        .onAppear(){
            self.viewModel.getJoinedGroup()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Notification), perform: { (obj) in
            if let userInfo = obj.userInfo,
               let publication = userInfo["publication"] as? Notification_NotifyObjectResponse {
                if publication.notifyType == "new-peer" ||  publication.notifyType == "new-group" {
                    self.viewModel.getJoinedGroup()
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage), perform: { (obj) in
            if let userInfo = obj.userInfo,
               let message = userInfo["message"] as? MessageModel {
                if message.groupID == ChatService.shared.openedGroupId { return }
                if message.groupType == "peer" {
                    self.messageData = MessagerBannerModifier.MessageData(senderName: RealmManager.shared.getSenderName(fromClientId: message.fromClientID, groupId: message.groupID), message: String(data: message.message, encoding: .utf8) ?? "x")
                } else {
                    self.messageData = MessagerBannerModifier.MessageData(groupName: RealmManager.shared.getGroupName(by: message.groupID), senderName: RealmManager.shared.getSenderName(fromClientId: message.fromClientID, groupId: message.groupID), message: String(data: message.message, encoding: .utf8) ?? "x")
                }
                self.isShowMessageBanner = true
                self.viewModel.reloadData()
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
            self.viewModel.getJoinedGroup()
        })
    }
}

fileprivate struct ListGroupView<CreateNewGroupView, Destination, Content>: View where CreateNewGroupView: View, Destination: View, Content: View {
    // MARK: - State
    @State private var isExpanded: Bool = true
    
    // MARK: - Binding
    
    // MARK: - Variables
    var titleSection: String
    var groups: [GroupModel]
    var createNewGroup: CreateNewGroupView
    var detail: (GroupModel) -> Destination
    var content: (GroupModel) -> Content
    
    // MARK: - Content view
    var body: some View {
        VStack(spacing: 16) {
            SectionGroupView(titleSection: "\(titleSection) (\(groups.count))", destination: createNewGroup, isExpanded: $isExpanded)
            
            if isExpanded && !groups.isEmpty {
                ForEach(groups, id: \.groupID) { group in
                    NavigationLink(destination: detail(group), label: {
                        content(group)
                        Spacer()
                    })
                }
                .padding(.leading, 16)
            }
        }
    }
}

fileprivate struct SectionGroupView<Destination>: View where Destination: View {
    // MARK: - Variables
    var titleSection: String
    var destination: Destination
    
    // MARK: - Binding
    @Binding var isExpanded: Bool
    
    // MARK: - Content view
    var body: some View {
        HStack() {
            Text(titleSection)
                .font(AppTheme.fonts.linkMedium.font)
                .foregroundColor(AppTheme.colors.gray1.color)
            
            Button(action: {
                self.isExpanded.toggle()
            }, label: {
                Image(isExpanded ? "Chev-down" : "Chev-up")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 18, height: 18, alignment: .center)
                    .foregroundColor(AppTheme.colors.gray1.color)
                    .padding(.all, 6)
            })
            
            Spacer()
            
            NavigationLink(destination: destination) {
                Image("Plus")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                    .foregroundColor(AppTheme.colors.gray1.color)
            }
        }
    }
}
