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
                    VStack(spacing: 0) {
                        VideoContainerView(viewModel: viewModel)
                        CallVideoActionView(viewModel: viewModel)
                            .frame(height: 120)
                    }
                    .edgesIgnoringSafeArea(.all)
                    
                    SingleVideoCallInfoView(viewModel: viewModel)
                } else {
                    CallVoiceActionView(viewModel: viewModel)
                    SingleVoiceCallInfoView(viewModel: viewModel)
                }
            }
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
}

struct SingleVoiceCallInfoView: View {
    @ObservedObject var viewModel: CallViewModel
    
    func image(withName: String?) -> Image? {
        guard let name = withName, !name.isEmpty else {
            return nil
        }
        return Image(name)
    }
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                Spacer()
                
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 60)
                    
                    if viewModel.callType == .audio, viewModel.callStatus != .answered, !viewModel.getStatusMessage().isEmpty {
                        Text(viewModel.getStatusMessage())
                            .font(AppTheme.fonts.textMedium.font)
                            .foregroundColor(AppTheme.colors.gray5.color)
                    }
                    
                    ChannelUserAvatar(avatarSize: 160, text: viewModel.getUserName(), font: AppTheme.fonts.defaultFont(ofSize: 72).font, image: image(withName: viewModel.callBox?.avatar), status: .none, gradientBackgroundType: GradientBackgroundType.accent)
                    
                    VStack(spacing: 8) {
                        Text(viewModel.getUserName())
                            .font(AppTheme.fonts.displayMediumBold.font)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                            .lineLimit(2)
                            .padding(.horizontal, 16)
                            .layoutPriority(1)
                        
                        if viewModel.callType == .audio, viewModel.callStatus == .answered {
                            Text(viewModel.timeCall)
                                .font(AppTheme.fonts.displaySmall.font)
                                .foregroundColor(AppTheme.colors.offWhite.color)
                        }
                    }
                    
                    Spacer()
                    
                    Spacer()
                        .frame(height: reader.size.height/2)
                }
                
                Spacer()
            }
            .frame(width: reader.size.width, height: reader.size.height)
        }
        
        .edgesIgnoringSafeArea(.top)
    }
}

struct SingleVideoCallInfoView: View {
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
                .frame(height: 60)
            
            if viewModel.callStatus != .answered {
                Text(viewModel.getStatusMessage())
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.gray5.color)
                
                Text(viewModel.getUserName())
                    .font(AppTheme.fonts.displayMediumBold.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
            } else {
                HStack(alignment: .top, spacing: 0) {
                    Button(action: {}, label: {
                        Image("ic_back")
                            .frame(width: 24, height: 24, alignment: .leading)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                    })
                    .padding(.all, 8)
                    .padding(.leading, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.getUserName())
                            .font(AppTheme.fonts.displayMediumBold.font)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                        
                        Text(viewModel.timeCall)
                            .font(AppTheme.fonts.displaySmall.font)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                    }
                    
                    Spacer()
                }
                
            }
            
                
            Spacer()
        }
        .edgesIgnoringSafeArea(.top)
    }
}
    
struct PeerCallView_Previews: PreviewProvider {
    static var previews: some View {
        PeerCallView(viewModel: CallViewModel())
    }
}

struct SingleVoiceCallInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SingleVoiceCallInfoView(viewModel: CallViewModel())
    }
}
