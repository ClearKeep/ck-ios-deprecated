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
                VStack(spacing: 5) {
//                    if isShowAvatarAndUserName {
//                        HStack {
//                            Spacer()
//
//                        }.padding(.top, 10)
//                    }
                    HStack {
                        Text(dateTime())
                        .font(AppTheme.fonts.textXSmall.font)
                        .foregroundColor(AppTheme.colors.gray3.color)
                        Spacer()
                        Text(stringValue())
                            .padding([.top , .bottom], 12)
                            .padding([.leading , .trailing] , 24)
                            .background(AppTheme.colors.gray2.color)
                            .font(AppTheme.fonts.textMedium.font)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                            .clipShape(BubbleArrow(rectCorner: rectCorner))
                            .lineSpacing(10)
                    }
                }
            }
            else {
                if isGroup {
                    VStack(alignment: .leading, spacing: 0){
                        HStack(spacing: 0) {
                            if isShowAvatarAndUserName {
                                ChannelUserAvatar(avatarSize: 16, text: getDisplayName())
                                Text(getDisplayName())
                                    .font(AppTheme.fonts.linkSmall.font)
                                    .foregroundColor(UIColor.random().color)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                        }
                        HStack(alignment: .firstTextBaseline){
                            Text(stringValue())
                                .padding([.top , .bottom], 12)
                                .padding([.leading , .trailing] , 24)
                                .background(AppTheme.colors.primary.color)
                                .font(AppTheme.fonts.textMedium.font)
                                .foregroundColor(AppTheme.colors.offWhite.color)
                                .clipShape(BubbleArrow(rectCorner: rectCorner))
                                .lineSpacing(10)
                            Button(action: {
                                
                            }, label: {
                                Image("ic_emoji")
                                    .foregroundColor(AppTheme.colors.gray1.color)
                            })
                            
                            Spacer()
                            Text(dateTime())
                                .font(AppTheme.fonts.textXSmall.font)
                                .padding(.leading, 4)
                                .foregroundColor(AppTheme.colors.gray3.color)
                        }
                    }
                } else {
                    VStack(spacing: 5){
//                        if isShowAvatarAndUserName {
//                            HStack {
//                                Text(dateTime())
//                                    .font(AppTheme.fonts.textXSmall.font)
//                                    .foregroundColor(AppTheme.colors.gray3.color)
//                                Spacer()
//                            }.padding(.top, 10)
//                        }
                        
                        HStack(alignment: .firstTextBaseline) {
                            Text(stringValue())
                                .padding([.top , .bottom], 12)
                                .padding([.leading , .trailing] , 24)
                                .background(AppTheme.colors.primary.color)
                                .font(AppTheme.fonts.textMedium.font)
                                .foregroundColor(AppTheme.colors.offWhite.color)
                                .clipShape(BubbleArrow(rectCorner: rectCorner))
                                .lineSpacing(10)
                            Button(action: {
                                
                            }, label: {
                                Image("ic_emoji")
                                    .foregroundColor(AppTheme.colors.gray1.color)
                            })                            
                            Spacer()
                            Text(dateTime())
                                .font(AppTheme.fonts.textXSmall.font)
                                .foregroundColor(AppTheme.colors.gray3.color)
                        }
                        
                    }
                }
            }
        }
        .id(msg.id)
    }
    
    private func dateTime() -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(msg.createdAt/1000))
        let formatDate = DateFormatter()
        formatDate.dateFormat = "HH:mm"
        return formatDate.string(from: date as Date)
    }
    
    private func stringValue() -> String {
        let str = String(data: msg.message, encoding: .utf8) ?? "x"
        return str
    }
    
    private func getDisplayName() -> String {
        return RealmManager.shared.getDisplayNameSenderMessage(fromClientId: msg.clientID, groupID: msg.groupID)
    }
}

struct BubbleArrow : Shape {
    var rectCorner: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 32, height: 32))
        return Path(path.cgPath)
    }
}
