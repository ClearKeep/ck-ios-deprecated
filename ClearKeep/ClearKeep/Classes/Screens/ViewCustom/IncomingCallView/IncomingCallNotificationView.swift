//
//  IncomingCallNotificationView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 12/05/2021.
//

import SwiftUI

struct IncomingCallNotificationView: View {
    let title: String
    let callerName: String
    let isShowAvatar: Bool
    let avatarImage: Image?
    
    let declineAction: VoidCompletion
    let answerAction: VoidCompletion
    let tapOnBannerAction: VoidCompletion
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                if isShowAvatar {
                    ChannelUserAvatar(avatarSize: 56, text: callerName, image: avatarImage, status: .none, gradientBackgroundType: .primary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(AppTheme.fonts.textSmall.font)
                        .foregroundColor(AppTheme.colors.success.color)
                    
                    Text(callerName)
                        .font(AppTheme.fonts.linkLarge.font)
                        .foregroundColor(AppTheme.colors.gray1.color)
                }
                .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            HStack(spacing: 16) {
                Spacer()
                
                Button(action: declineAction) {
                    Text("Decline")
                }
                .frame(width: 134, height: 40, alignment: .center)
                .background(AppTheme.colors.error.color)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                
                Button(action: answerAction) {
                    Text("Answer")
                }
                .frame(width: 134, height: 40, alignment: .center)
                .background(AppTheme.colors.success.color)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Spacer()
                
            }
            .font(AppTheme.fonts.linkSmall.font)
            .foregroundColor(AppTheme.colors.offWhite.color)
        }
        .embededInCardView(showShadow: true)
        .onTapGesture {
            tapOnBannerAction()
        }
        .transition(.move(edge: .top))
    }
}

struct IncomingCallNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            IncomingCallNotificationView(title: "Incoming voice call", callerName: "Alex Sancho", isShowAvatar: true, avatarImage: Image("ic_app"), declineAction: {}, answerAction: {}, tapOnBannerAction: {})
            
            IncomingCallNotificationView(title: "Incoming Voice Group call", callerName: "Dev Group", isShowAvatar: false, avatarImage: nil, declineAction: {}, answerAction: {}, tapOnBannerAction: {})

        }
        .padding(.all, 16)
        .padding(.top, 40)
        .grandientBackground()
    }
}
