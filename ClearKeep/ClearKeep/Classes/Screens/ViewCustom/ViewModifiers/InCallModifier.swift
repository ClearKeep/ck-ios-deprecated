//
//  InCallModifier.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 6/2/21.
//

import SwiftUI

struct InCallModifier: ViewModifier {
    // MARK: - Environment
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    @State var isInMinimizeMode: Bool = false
    @Binding var isInCall: Bool
    @ObservedObject var callViewModel: CallViewModel
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            VStack {
                if isInCall {
                    Spacer()
                }
                content
            }
            if isInCall {
                HStack(alignment: .bottom) {
                    if !callViewModel.callGroup {
                        ChannelUserAvatar(avatarSize: 34, text: callViewModel.getUserName(), image: nil, status: .none, gradientBackgroundType: .primary)
                            .padding(.trailing, 16)
                            .padding(.leading, 24)
                    }
                    VStack (alignment: .leading) {
                        Spacer()
                        Text(callViewModel.getUserName())
                            .font(AppTheme.fonts.linkMedium.font)
                            .foregroundColor(AppTheme.colors.gray5.color)
                            .lineLimit(1)
                        Text("Tap here to return to call screen")
                            .font(AppTheme.fonts.textXSmall.font)
                            .foregroundColor(AppTheme.colors.background.color)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(callViewModel.timeCall)
                        .font(AppTheme.fonts.linkXSmall.font)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                        .lineLimit(1)
                        .padding(.trailing, 24)
                }
                .padding(.bottom, 16)
                .frame(height: globalSafeAreaInsets().top + 50)
                .background(RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight]).fill(AppTheme.colors.success.color))
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    callViewModel.backHandler = {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissModal"), object: nil)
                        withAnimation {
                            isInMinimizeMode = true
                            isInCall = true
                        }
                    }
                    
                    isInMinimizeMode = false
                    
                    self.viewControllerHolder?.present(style: .overFullScreen, builder: {
                        CallView(viewModel: callViewModel)
                    }, completion: {
                    })
                }
                .transition(.move(edge: .top))
                
                if isInMinimizeMode {
                    VStack {
                        Spacer()
                        HStack(alignment: .top) {
                            Spacer()
                            if let videoView = callViewModel.remoteVideoView {
                                VideoView(rtcVideoView: videoView)
                                    .frame(width: 120,
                                           height: 180,
                                           alignment: .center)
                                    .background(Color.black)
                                    .clipShape(Rectangle())
                                    .cornerRadius(10)
                                    .padding(.trailing, 16)
                                    .padding(.bottom, 68)
                                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                    .animation(.easeInOut(duration: 0.6))
                            }
                        }
                    }.padding(.trailing, 16)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.receiveCall)) { (obj) in
            callViewModel.backHandler = {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissModal"), object: nil)
                
                withAnimation {
                    isInCall = true
                    isInMinimizeMode = true
                }
            }
            self.viewControllerHolder?.present(style: .overFullScreen, builder: {
                CallView(viewModel: callViewModel)
            }, completion: {
            })
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.endCall)) { (obj) in
            withAnimation {
                isInCall = false
                isInMinimizeMode = false
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "dismissModal"), object: nil)
        }
    }
}

extension View {
    func inCallModifier(callViewModel: CallViewModel, isInCall: Binding<Bool>) -> some View {
        self.modifier(InCallModifier(isInCall: isInCall, callViewModel: callViewModel))
    }
}
