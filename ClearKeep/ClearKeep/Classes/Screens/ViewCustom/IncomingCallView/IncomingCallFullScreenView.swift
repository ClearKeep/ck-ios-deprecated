//
//  IncomingCallFullScreenView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 12/05/2021.
//

import SwiftUI

struct IncomingCallFullScreenView: View {
    
    @ObservedObject var viewModel: IncomingCallFullScreenViewModel
        
    var body: some View {
        VStack {
            Group {
                if viewModel.isGroupCall {
                    groupInfoView()
                } else {
                    callerInfoView()
                }
            }
            .padding(.top, 100)
            
            Spacer()
            
            Group {
                if viewModel.isIncomingCall {
                    callButtonForIncomingCall()
                } else {
                    callButtonForOutgoingCall()
                }
            }
            .padding(.bottom, 110)
        }
        .blurBackground(backgroundImage: viewModel.isGroupCall ? nil : viewModel.avatar)
    }
    
    private func groupInfoView() -> some View {
        VStack(spacing: 8) {
            Text(viewModel.callingStatusText)
                .font(AppTheme.fonts.textMedium.font)
                .foregroundColor(AppTheme.colors.offWhite.color)
                .lineLimit(2)
            
            Text(viewModel.callerName)
                .font(AppTheme.fonts.displayMediumBold.font)
                .foregroundColor(AppTheme.colors.offWhite.color)
                .lineLimit(2)
                .padding(.horizontal, 16)
        }
    }
    
    private func callerInfoView() -> some View {
        VStack(spacing: 32) {
            if !viewModel.callingStatusText.isEmpty {
                Text(viewModel.callingStatusText)
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.gray5.color)
            }
            
            ChannelUserAvatar(avatarSize: 160, text: viewModel.callerName, font: AppTheme.fonts.defaultFont(ofSize: 72).font, image: viewModel.avatar, status: .none, gradientBackgroundType: GradientBackgroundType.accent)
            
            VStack(spacing: 8) {
                Text(viewModel.callerName)
                    .font(AppTheme.fonts.displayMediumBold.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
                
                Text(viewModel.timeString)
                    .font(AppTheme.fonts.displaySmall.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
            }
        }
    }
    
    private func callButtonForIncomingCall() -> some View {
        HStack {
            VStack {
                ButtonCallStyle(imageName: "Phone-off", backgroundColor: AppTheme.colors.error.color, action: {})
                
                Text("Decline")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
            }
            
            Spacer()
            
            VStack {
                ButtonCallStyle(imageName: viewModel.isVideoCall ? "Video" : "Phone call", backgroundColor: AppTheme.colors.success.color, action: {})
                
                Text("Answer")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
            }
        }
        .padding(.horizontal, 40)
    }
    
    private func callButtonForOutgoingCall() -> some View {
        HStack {
            Spacer()
            VStack {
                ButtonCallStyle(imageName: "Phone-off", backgroundColor: AppTheme.colors.error.color, action: {})
                
                Text("Cancel")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
            }
            Spacer()
        }
    }
}

struct ButtonCallStyle: View {
    let imageName: String
    var backgroundColor: Color
    var action: VoidCompletion
    
    var body: some View {
        Button(action: {}, label: {
            Image(imageName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(AppTheme.colors.offWhite.color)
                .frame(width: 28, height: 28)
                .padding(.all, 16)
                .background(backgroundColor)
                .clipShape(Circle())
        })
    }
}

struct IncomingCallSingleView_Previews: PreviewProvider {
    static let viewModel = IncomingCallFullScreenViewModel(backgroundImage: nil,
                                                            avatar: nil,
                                                            callerName: "Alex",
                                                            isIncomingCall: true,
                                                            isGroupCall: false,
                                                            isVideoCall: false)

    static var previews: some View {
        IncomingCallFullScreenView(viewModel: viewModel)
            //.background(Color.gray)

//        IncomingCallFullScreenView(backgroundImage: Image("ic_app"), isIncomingCall: true, avatar: Image("ic_app"), callerName: "Alex Sancho", timeString: "01:05", callingStatusText: "Incoming Video Group Call", isGroupCall: true, isVideoCall: false)
//            .background(Color.gray)
    }
}
