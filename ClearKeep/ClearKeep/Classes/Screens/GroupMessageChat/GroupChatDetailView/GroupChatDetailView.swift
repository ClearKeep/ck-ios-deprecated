//
//  GroupChatDetailView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/22/21.
//

import SwiftUI

struct GroupChatDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var groupModel: GroupModel? = nil
    
    @State private var isShowingGroupChatMemberView = false
    
    
    init(groupModel: GroupModel?) {
        self.groupModel = groupModel
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing : -8) {
                if let lstUser = self.groupModel?.lstClientID {
                    if lstUser.count < 5 {
                        ForEach(lstUser){ user in
                            ChannelUserAvatar(avatarSize: 36, statusSize: 8, text: user.username, image: nil, status: .none, gradientBackgroundType: .primary)
                        }
                    } else {
                        let lst = lstUser[0..<3]
                        ForEach(lst){ user in
                            ChannelUserAvatar(avatarSize: 36, statusSize: 8, text: user.username, image: nil, status: .none, gradientBackgroundType: .primary)
                        }
                        
                        let count = lstUser.count - lst.count
                        
                        ZStack(alignment: .center){
                            LinearGradient(gradient: Gradient(colors: [AppTheme.colors.gradientPrimaryDark.color, AppTheme.colors.gradientPrimaryLight.color]), startPoint: .leading, endPoint: .trailing)
                                .frame(width: 36, height: 36, alignment: .center)
                                .clipShape(Circle())
                            
                            Text("+\(count)")
                                .font(AppTheme.fonts.linkSmall.font)
                                .frame(alignment: .center)
                                .foregroundColor(AppTheme.colors.offWhite.color)
                        }
                    }
                }
            }.padding(.top, 31)
            
            HStack {
                ButtonWithTitleAction("ic_action_call", "Audio")
                Spacer()
                ButtonWithTitleAction("ic_action_video_call", "Video")
                Spacer()
                ButtonWithTitleAction("ic_action_notify", "Mute")
            }
            .padding(.horizontal, 52)
            .padding(.vertical, 24)
            
            VStack(spacing: 16) {
            NavigationLink(destination: GroupChatMemberView(groupModel: self.groupModel), isActive: $isShowingGroupChatMemberView) {}
                ButtonSettingApp("user", "See Members", false) {
                    isShowingGroupChatMemberView = true
                }
                ButtonSettingApp("user-plus", "Add Members", false){
                    
                }
                
                ButtonSettingApp("user-off", "Remove Members", false){
                    
                }
                
                ButtonSettingApp("ic_photo", "View Photos/Video", false){
                    
                }
                
                ButtonSettingApp("Search", "Search in Conversation", false){
                    
                }
                
                ButtonSettingApp("ic_alert", "Report", true){
                    
                }
                
                ButtonSettingApp("Logout", "Leave Group", true){
                    
                }
                
            }
            .padding([.leading, .trailing], 16)
            
            Spacer()
        }
        .applyNavigationBarPlainStyleDark(title: groupModel?.groupName ?? "Group", leftBarItems: {
            Image("Chev-left")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24, alignment: .leading)
                .foregroundColor(AppTheme.colors.black.color)
                .onTapGesture(count: 1, perform: {
                    presentationMode.wrappedValue.dismiss()
                })
        }, rightBarItems: {
            Image("pencil")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24, alignment: .leading)
                .foregroundColor(AppTheme.colors.black.color)
        })
    }
}

struct GroupChatDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        GroupChatDetailView(groupModel: nil)
    }
}
