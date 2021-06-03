//
//  MessageBubble.swift
//  ClearKeep
//
//  Created by VietAnh on 1/15/21.
//

import SwiftUI

struct MessageBubble: View {
    var msg : MessageModel
    var userName: String? = nil
    var isGroup: Bool = false
    var isShowAvatarAndUserName: Bool = false
    var rectCorner: UIRectCorner
    let maxWidthBuble = UIScreen.main.bounds.width * 0.67
    
    var body: some View {
        // Automatic scroll To Bottom...
        // First Assigning Id To Each Row...
        HStack(alignment: .top,spacing: 10){
            if msg.myMsg {
                MyMessageBubble(msg: msg, rectCorner: rectCorner)
            } else {
                if isGroup {
                    GroupMessageBubble(isShowAvatarAndUserName: isShowAvatarAndUserName, msg: msg, rectCorner: rectCorner)
                } else {
                    PeerMessageBubble(msg: msg, rectCorner: rectCorner)
                }
            }
        }
        .id(msg.id)
    }
}

struct BubbleArrow : Shape {
    var rectCorner: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 32, height: 32))
        return Path(path.cgPath)
    }
}

fileprivate struct MyMessageBubble: View {
    var msg : MessageModel
    var rectCorner: UIRectCorner
    
    var body: some View {
        HStack {
            Text(msg.getSentTime())
                .font(AppTheme.fonts.textXSmall.font)
                .foregroundColor(AppTheme.colors.gray3.color)
            Spacer()
            Text(msg.getMessage()).modifier(MessageBubbleModifier(rectCorner: rectCorner))
        }
    }
}

fileprivate struct PeerMessageBubble: View {
    var msg : MessageModel
    var rectCorner: UIRectCorner
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(msg.getMessage()).modifier(MessageBubbleModifier(rectCorner: rectCorner))
            ReactionView()
            Spacer()
            Text(msg.getSentTime())
                .font(AppTheme.fonts.textXSmall.font)
                .foregroundColor(AppTheme.colors.gray3.color)
        }
    }
}

fileprivate struct GroupMessageBubble: View {
    var isShowAvatarAndUserName: Bool = false
    var msg : MessageModel
    var rectCorner: UIRectCorner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack(spacing: 0) {
                if isShowAvatarAndUserName {
                    ChannelUserAvatar(avatarSize: 16, text: msg.getSenderName())
                    Text(msg.getSenderName())
                        .font(AppTheme.fonts.linkSmall.font)
                        .foregroundColor(UIColor.random().color)
                        .padding(.leading, 8)
                    Spacer()
                }
            }
            HStack(alignment: .firstTextBaseline){
                Text(msg.getMessage()).modifier(MessageBubbleModifier(rectCorner: rectCorner))
                ReactionView()
                Spacer()
                Text(msg.getSentTime())
                    .font(AppTheme.fonts.textXSmall.font)
                    .padding(.leading, 4)
                    .foregroundColor(AppTheme.colors.gray3.color)
            }
        }
    }
}

fileprivate struct CallMessageBubble: View {
    var isGroup: Bool
    var type: MessageCallType
    var rectCorner: UIRectCorner
    var callBackHandler: (() -> ())
    
    var body: some View {
        GeometryReader { reader in
            VStack(alignment: .center) {
                VStack (alignment: .leading) {
                    HStack (spacing: 4) {
                        Image("Phone-off")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 13, height: 13, alignment: .center)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                        Text(type != .missed ? "Call Ended" : "Missed Call")
                            .font(AppTheme.fonts.linkMedium.font)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                        Spacer()
                    }
                    if type != .missed {
                        HStack {
                            if isGroup {
                                ListUserIcon(users: [GroupMember(id: "", username: "N"), GroupMember(id: "", username: "Y")], avatarSize: 16)
                                Text("2 Joined")
                                    .font(AppTheme.fonts.textXSmall.font)
                                    .foregroundColor(AppTheme.colors.gray4.color)
                                Spacer()
                            }
                            Text("04:24")
                                .font(AppTheme.fonts.textXSmall.font)
                                .foregroundColor(AppTheme.colors.background.color)
                        }
                        .frame(height: 16)
                    }
                }
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing], 24)
                Button(action: {
                    callBackHandler()
                }) {
                    Text("Call Back")
                        .font(AppTheme.fonts.linkSmall.font)
                        .padding(.leading, 4)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                }
                .frame(width: reader.size.width, height: 40)
                .background(Color.white.opacity(0.4))
            }
        }
        .if(type != .missed, transform: { view in
            view.background(AppTheme.colors.primary.color)
        })
        .if(type == .missed, transform: { view in
            view.background(AppTheme.colors.secondary.color)
        })
        .clipShape(BubbleArrow(rectCorner: rectCorner))
    }
}

struct CallMessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GeometryReader { reader in
                CallMessageBubble(isGroup: true, type: .ended, rectCorner: [.bottomLeft, .bottomRight, .topRight], callBackHandler: {})
                    .frame(width: reader.size.width*2/3)
//                CallMessageBubble(type: .missed, rectCorner: [.bottomLeft, .bottomRight, .topLeft], callBackHandler: {})
//                    .frame(width: reader.size.width*2/3)
                Spacer()
            }
        }
        .previewLayout(.fixed(width: 300, height: 100))
    }
}

fileprivate struct ReactionView: View {
    var body: some View {
        ZStack {
            Button(action: {
                
            }, label: {
                Image("ic_emoji")
                    .foregroundColor(AppTheme.colors.gray1.color)
            })
        }
    }
}

fileprivate struct MessageBubbleModifier: ViewModifier {
    var rectCorner: UIRectCorner
    
    func body(content: Content) -> some View {
        content
            .padding([.top , .bottom], 12)
            .padding([.leading , .trailing] , 24)
            .background(AppTheme.colors.primary.color)
            .font(AppTheme.fonts.textMedium.font)
            .foregroundColor(AppTheme.colors.offWhite.color)
            .clipShape(BubbleArrow(rectCorner: rectCorner))
            .lineSpacing(10)
    }
}

struct ListUserIcon: View {
    var users: [GroupMember] = []
    var avatarSize: CGFloat = 16
    var body: some View {
        HStack (spacing: -8) {
            ForEach(users){ user in
                ChannelUserAvatar(avatarSize: avatarSize, text: user.username, image: nil, status: .none, gradientBackgroundType: .primary)
            }
        }
    }
}
