//
//  MessagerBannerModifier.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/26/21.
//

import SwiftUI

struct MessagerBannerModifier: ViewModifier {
    
    struct MessageData {
        var groupName: String = ""
        var senderName: String = ""
        var userIcon: Image? = nil
        var message: String = ""
        private(set) var isGroup: Bool = false
        
        init() {}
        
        init(senderName: String, userIcon: Image? = nil, message: String) {
            self.senderName = senderName
            self.userIcon = userIcon
            self.message = message
            self.isGroup = false
        }
        
        init(groupName: String, senderName: String, userIcon: Image? = nil, message: String) {
            self.senderName = senderName
            self.userIcon = userIcon
            self.message = message
            self.isGroup = true
        }
    }
    
    @Binding var data: MessageData
    @Binding var show: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                VStack {
                    VStack(spacing: 16) {
                        Group {
                            if data.isGroup {
                                viewForGroup()
                            } else {
                                viewForPeer()
                            }
                        }
                        
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Text("Reply")
                            }
                            Button(action: {}) {
                                Text("Mute")
                            }
                            
                            Spacer()
                        }
                        .font(AppTheme.fonts.linkSmall.font)
                        .foregroundColor(AppTheme.colors.primary.color)
                    }
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                    )
                    .shadow(color: AppTheme.colors.shadow.color, radius: 24, x: 0, y: 8)
                    
                    Spacer()
                }
                .padding(.top, 10)
                .padding([.leading, .trailing], 16)
                .animation(.easeInOut)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        self.show = false
                    }
                }.onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.show = false
                        }
                    }
                })
            }
        }
    }

    private func viewForGroup() -> some View {
            
        VStack(alignment: .leading, spacing: 6) {
            Text("New message from \(data.groupName)")
                .font(AppTheme.fonts.textSmall.font)
                .foregroundColor(AppTheme.colors.gray3.color)
                .lineLimit(1)
            
            HStack() {
                ChannelUserAvatar(avatarSize: 24, text: data.senderName, image: data.userIcon, status: .none, gradientBackgroundType: .primary)
                    .padding(.trailing, 16)
                Text(data.senderName + ":")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.gray1.color)
                    .lineLimit(1)
                Text(data.message)
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.gray1.color)
                    .lineLimit(1)
                
                Spacer()
            }
        }
    }
    
    private func viewForPeer() -> some View {
        HStack(spacing: 16) {
            ChannelUserAvatar(avatarSize: 56, text: data.senderName, image: data.userIcon, status: .none, gradientBackgroundType: .primary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("New message from \(data.senderName)")
                    .font(AppTheme.fonts.textSmall.font)
                    .foregroundColor(AppTheme.colors.gray3.color)
                    .lineLimit(1)
                
                Text(data.message)
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.gray1.color)
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
}

extension View {
    func messagerBannerModifier(data: Binding<MessagerBannerModifier.MessageData>, show: Binding<Bool>) -> some View {
        self.modifier(MessagerBannerModifier(data: data, show: show))
    }
}
