//
//  ServerMainView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/22/21.
//

import SwiftUI

struct ServerMainView: View {
    @State private var searchText: String = ""
    @State private var numberGroupChat: Int = 4
    @State private var numberDirectMessages: Int = 5
    
    @State private var isGroupChatExpanded: Bool = true
    @State private var isDirectMessageExpanded: Bool = true
    
    @State private var groupChatModels: [GroupChatNewMessageModel] = GroupChatNewMessageModel.testList
    @State private var directMessageModels: [DirectMessageNewMessageModel] = DirectMessageNewMessageModel.testList
    
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("CK Development")
                    .font(AppTheme.fonts.displaySmallBold.font)
                    .foregroundColor(AppTheme.colors.black.color)
                Spacer()
                Button(action: {}, label: {
                    Image("Hamburger")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36, alignment: .center)
                })
            }
            
            WrappedTextFieldWithLeftIcon("Search", leftIconName: "Search", shouldShowBorderWhenFocused: false, keyboardType: UIKeyboardType.default, text: $searchText, errorMessage: .constant(""))
            
            Button(action: {}, label: {
                HStack {
                    Image("Notes")
                    Text("Notes")
                        .font(AppTheme.fonts.linkMedium.font)
                        .foregroundColor(AppTheme.colors.gray1.color)
                    Spacer()
                }
            })
            
            groupChatSection()
            
            directMessageSection()
            
            Spacer()
        }
        .padding()
    }
}

extension ServerMainView {
    
    func groupChatSection() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Group Chat (\(groupChatModels.count))")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.gray1.color)
                
                Button(action: {}, label: {
                    Image(isGroupChatExpanded ? "Chev-down" : "Chev-up")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18, height: 18, alignment: .center)
                        .padding(.all, 6)
                })

                Spacer()
                
                Button(action: {}, label: {
                    Image("Plus")
                })
            }
            
            if isGroupChatExpanded && !groupChatModels.isEmpty {
                VStack(spacing: 16) {
                    ForEach(0..<groupChatModels.count) { index in
                        let item = groupChatModels[index]
                        Button(action: {}, label: {
                            HStack {
                                Text("\(item.groupName)")
                                    .font(AppTheme.fonts.linkSmall.font)
                                    .foregroundColor(AppTheme.colors.gray1.color)
                                Spacer()
                                
                                if item.messageNumber > 0 {
                                    Text("\(item.messageNumber)")
                                        .font(AppTheme.fonts.textXSmall.font)
                                        .foregroundColor(AppTheme.colors.offWhite.color)
                                        .frame(width: 24, height: 24, alignment: .center)
                                        .background(AppTheme.colors.secondary.color)
                                        .clipShape(Circle())
                                }
                            }
                        })
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
    
    func directMessageSection() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Direct Messages (\(directMessageModels.count))")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.gray1.color)
                
                Button(action: {}, label: {
                    Image(isDirectMessageExpanded ? "Chev-down" : "Chev-up")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18, height: 18, alignment: .center)
                        .padding(.all, 6)
                })

                Spacer()
                
                Button(action: {}, label: {
                    Image("Plus")
                })
            }
            
            if isGroupChatExpanded && !directMessageModels.isEmpty {
                VStack(spacing: 16) {
                    ForEach(0..<directMessageModels.count) { index in
                        let item = directMessageModels[index]
                        Button(action: {}, label: {
                            HStack {
                                ChannelUserAvatar(avatarSize: 24, statusSize: 8, text: item.userName, font: AppTheme.fonts.linkSmall.font, image: item.imageName.isEmpty ? nil : Image(item.imageName), status: item.status, gradientBackgroundType: .accent)
                                
                                Text("\(item.userName)")
                                    .font(AppTheme.fonts.linkSmall.font)
                                    .foregroundColor(AppTheme.colors.gray1.color)
                                
                                Spacer()
                                
                                if item.messageNumber > 0 {
                                    Text("\(item.messageNumber)")
                                        .font(AppTheme.fonts.textXSmall.font)
                                        .foregroundColor(AppTheme.colors.offWhite.color)
                                        .frame(width: 24, height: 24, alignment: .center)
                                        .background(AppTheme.colors.secondary.color)
                                        .clipShape(Circle())
                                }
                            }
                        })
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
}

struct ServerMainView_Previews: PreviewProvider {
    static var previews: some View {
        ServerMainView()
    }
}

struct GroupChatNewMessageModel {
    var groupName: String
    var messageNumber: Int
    
    static let testList: [GroupChatNewMessageModel] = [
        GroupChatNewMessageModel(groupName: "Discussion", messageNumber: 2),
        GroupChatNewMessageModel(groupName: "UI Design", messageNumber: 0),
        GroupChatNewMessageModel(groupName: "Front-end Development", messageNumber: 12),
        GroupChatNewMessageModel(groupName: "Back-end Development", messageNumber: 4)
    ]
}

struct DirectMessageNewMessageModel {
    var userName: String
    var messageNumber: Int
    var imageName: String
    var status: UserOnlineStatus
    
    static let testList: [DirectMessageNewMessageModel] = [
        DirectMessageNewMessageModel(userName: "Alex", messageNumber: 1, imageName: "ic_app", status: .active),
        DirectMessageNewMessageModel(userName: "Alex 2", messageNumber: 8, imageName: "ic_app", status: .active),
        DirectMessageNewMessageModel(userName: "Alex 3", messageNumber: 0, imageName: "ic_app", status: .active),
        DirectMessageNewMessageModel(userName: "Alex 4", messageNumber: 11, imageName: "ic_app", status: .doNotDisturb),
        DirectMessageNewMessageModel(userName: "Alex 5", messageNumber: 12, imageName: "", status: .none)
    ]
}
