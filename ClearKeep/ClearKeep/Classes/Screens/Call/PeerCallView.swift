//
//  PeerCallView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 18/05/2021.
//

import SwiftUI

struct PeerCallView: View {
    
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        GeometryReader{ reader in
            ZStack(alignment: .top) {
                Image("ic_app")
                    .resizable()
                    .frame(width: reader.frame(in: .global).width, height: reader.frame(in: .global).height, alignment: .center)
                    .blur(radius: 70)
                    
                if viewModel.callType == .video {
                    VideoContainerView(viewModel: viewModel)
                    CallVideoActionView(viewModel: viewModel)
                } else {
                    singleCallInfoView()
                    CallVoiceActionView(viewModel: viewModel)
                }
            }
            .frame(width: reader.size.width)
            .grandientBackground()
            .edgesIgnoringSafeArea(.all)
            .onAppear(perform: {
                if let callBox = CallManager.shared.calls.first {
                    viewModel.updateCallBox(callBox: callBox)
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Notification), perform: { (obj) in
                viewModel.didReceiveMessageGroup(userInfo: obj.userInfo)
            })
        }

    }
    
    private func singleCallInfoView() -> some View {
        VStack(spacing: 32) {
            Spacer()
                .frame(height: 60)
            
            if viewModel.callType == .audio, viewModel.callStatus != .answered, !viewModel.getStatusMessage().isEmpty {
                Text(viewModel.getStatusMessage())
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.gray5.color)
            }
            
            ChannelUserAvatar(avatarSize: 160, text: viewModel.getUserName(), font: AppTheme.fonts.defaultFont(ofSize: 72).font, image: Image("ic_app"), status: .none, gradientBackgroundType: GradientBackgroundType.accent)
            
            VStack(spacing: 8) {
                Text(viewModel.getUserName())
                    .font(AppTheme.fonts.displayMediumBold.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
                
                if viewModel.callType == .audio, viewModel.callStatus == .answered {
                    Text(viewModel.timeCall)
                        .font(AppTheme.fonts.displaySmall.font)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                }
            }
            
            Spacer()
        }
    }
}

struct PeerCallView_Previews: PreviewProvider {
    static var previews: some View {
        PeerCallView(viewModel: CallViewModel())
    }
}
