//
//  GroupCallView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 19/05/2021.
//

import SwiftUI

struct GroupCallView: View {
    
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .top) {
                if viewModel.callType == .video {
                    VStack(spacing: 0) {
                        VideoContainerView(viewModel: viewModel)
                        CallVideoActionView(viewModel: viewModel)
                            .frame(height: 120)
                    }
                } else {
                    if viewModel.callStatus != .answered {
                        groupCallInfoView()
                    }
                    
                    CallVoiceActionView(viewModel: viewModel)
                }
            }
            .onAppear(perform: {
                print("#GroupCallView Reader size \(reader.size) \(reader.safeAreaInsets)")
            })
            .if(viewModel.callStatus == .answered, transform: { view in
                view.applyNavigationBarCallStyle(title: viewModel.getUserName(), leftBarItems: {
                                Button(action: {}, label: {
                                    Image("ic_back")
                                        .frame(width: 24, height: 24, alignment: .leading)
                                        .foregroundColor(AppTheme.colors.offWhite.color)
                                })
                            }, rightBarItems: {
                                Text(viewModel.timeCall)
                                    .font(AppTheme.fonts.displaySmall.font)
                                    .foregroundColor(AppTheme.colors.offWhite.color)
                            })
            })
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
    
    private func groupCallInfoView() -> some View {
        VStack(spacing: 32) {
            Spacer()
                .frame(height: 60)
            
            VStack(spacing: 24) {
                Text(viewModel.getStatusMessage())
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.gray5.color)
                
                if viewModel.callType == .audio {
                    Text(viewModel.getUserName())
                        .font(AppTheme.fonts.displayMediumBold.font)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                }
            }
            
            Spacer()
        }
    }
}

struct GroupCallView_Previews: PreviewProvider {
    static var previews: some View {
        GroupCallView(viewModel: CallViewModel())
    }
}
