//
//  MessageNotificationView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/16/21.
//

import SwiftUI

struct MessageNotificationView: View {
    let title: String
    let message: String
    let userName: String
    let userIcon: Image?
    
    let replyAction: VoidCompletion
    let muteAction: VoidCompletion
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ChannelUserAvatar(avatarSize: 56, text: userName, image: userIcon, status: .none, gradientBackgroundType: .primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(AppTheme.fonts.textSmall.font)
                        .foregroundColor(AppTheme.colors.gray3.color)
                    
                    Text(message)
                        .font(AppTheme.fonts.textMedium.font)
                        .foregroundColor(AppTheme.colors.gray1.color)
                }
                .lineLimit(1)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                Button(action: replyAction) {
                    Text("Reply")
                }
                Button(action: muteAction) {
                    Text("Mute")
                }

                Spacer()
            }
            .font(AppTheme.fonts.linkSmall.font)
            .foregroundColor(AppTheme.colors.primary.color)
        }
        .padding(.horizontal, 4)
        .embededInCardView()
        .transition(.move(edge: .top))
    }
}

struct MessageNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MessageNotificationView(title: "New message from Alex", message: "Where are you? Pick up the phone now.", userName: "Alex", userIcon: Image("ic_app"), replyAction: {}, muteAction: {})
            
            MessageNotificationView(title: "New message from Alex", message: "Where are you? Pick up the phone now.", userName: "Alex", userIcon: nil, replyAction: {}, muteAction: {})

        }
        .padding()
        .padding(.top, 40)
        .grandientBackground()
    }
}
