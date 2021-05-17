//
//  OutgoingCallView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 5/17/21.
//

import SwiftUI

struct OutgoingCallView: View {
    
    @ObservedObject var viewModel: OutgoingCallViewModel
    
    var body: some View {
        VStack(spacing: 0.0) {
            Group {
                if viewModel.isGroupCall {
                    groupCallInfoView()
                } else {
                    singleCallInfoView()
                }
            }
            .padding(.top, 100)
            
            Spacer()
            
            callButtonForOutgoingCall()
                .padding(.bottom, 110)
        }
        .blurBackground(backgroundImage: viewModel.isGroupCall ? nil : viewModel.avatar)
    }
    
    private func groupCallInfoView() -> some View {
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
    
    private func singleCallInfoView() -> some View {
        
        VStack(spacing: 32) {
            if viewModel.isCallConnected {
                HStack {
                    Button(action: {
                        // TODO: back
                    }, label: {
                        Image("ic_back")
                            .frame(width: 24, height: 24, alignment: .leading)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                    })
                    .padding(.leading, 16)
                    
                    Spacer()
                }
            } else {
                if !viewModel.callingStatusText.isEmpty {
                    Text(viewModel.callingStatusText)
                        .font(AppTheme.fonts.textMedium.font)
                        .foregroundColor(AppTheme.colors.gray5.color)
                }
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
    
    private func callButtonForOutgoingCall() -> some View {
        HStack {
            Spacer()
            VStack {
                ButtonCallStyle(imageName: "Phone-off", backgroundColor: AppTheme.colors.error.color, action: {
                    viewModel.endCallButtonTapCompletion?()
                })
                
                Text(viewModel.isCallConnected ? "End Call" : "Cancel")
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
        Button(action: { action() }, label: {
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

struct OutgoingCallView_Previews: PreviewProvider {
    static let viewModel1 = OutgoingCallViewModel(backgroundImage: Image("ic_app"),
                                                  avatar: Image("ic_app"),
                                                  callerName: "Alex",
                                                  isGroupCall: false,
                                                  isVideoCall: false)
    
    static let viewModel2 = OutgoingCallViewModel(backgroundImage: Image("ic_app"),
                                                  avatar: Image("ic_app"),
                                                  callerName: "Alex",
                                                  isGroupCall: true,
                                                  isVideoCall: false)
    
    static let viewModel3 = OutgoingCallViewModel(backgroundImage: Image("ic_app"),
                                                  avatar: Image("ic_app"),
                                                  callerName: "Alex",
                                                  isGroupCall: false,
                                                  isVideoCall: true)
    
    static let viewModel4 = OutgoingCallViewModel(backgroundImage: Image("ic_app"),
                                                  avatar: Image("ic_app"),
                                                  callerName: "Alex",
                                                  isGroupCall: true,
                                                  isVideoCall: true)
    
    static var previews: some View {
        OutgoingCallView(viewModel: viewModel1)
            .edgesIgnoringSafeArea(.all)
        
        OutgoingCallView(viewModel: viewModel2)
            .edgesIgnoringSafeArea(.all)
        
        OutgoingCallView(viewModel: viewModel3)
            .edgesIgnoringSafeArea(.all)
        
        OutgoingCallView(viewModel: viewModel4)
            .edgesIgnoringSafeArea(.all)
    }
}

