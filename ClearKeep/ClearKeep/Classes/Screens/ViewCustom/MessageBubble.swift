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
    var body: some View {
        // Automatic scroll To Bottom...
        // First Assigning Id To Each Row...
        HStack(alignment: .top,spacing: 10){
            
            if msg.myMsg{
                HStack(alignment: .firstTextBaseline) {
                    // Show Time
                    Text(dateTime())
                        .font(AppTheme.fonts.textXSmall.font)
                        .padding(.top, 5)
                        .foregroundColor(AppTheme.colors.gray3.color)
                    Spacer()
                    if msg.photo == nil{
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
                                ChannelUserAvatar(avatarSize: 16, text: msg.fromDisplayName)
                                Text(msg.fromDisplayName)
                                    .font(AppTheme.fonts.linkSmall.font)
                                    .foregroundColor(AppTheme.colors.warning.color)
                                    .padding(.leading, 8)
                                Spacer()
                                Text(dateTime())
                                    .font(AppTheme.fonts.textXSmall.font)
                                    .padding(.top, 5)
                                    .foregroundColor(AppTheme.colors.gray3.color)
                            }
                        }
                        
                        if isShowAvatarAndUserName {
                            Text(stringValue())
                                .padding([.top , .bottom], 12)
                                .padding([.leading , .trailing] , 24)
                                .background(AppTheme.colors.primary.color)
                                .font(AppTheme.fonts.textMedium.font)
                                .foregroundColor(AppTheme.colors.offWhite.color)
                                .clipShape(BubbleArrow(rectCorner: rectCorner))
                                .lineSpacing(10)
                        } else {
                            HStack(alignment: .firstTextBaseline){
                                Text(stringValue())
                                    .padding([.top , .bottom], 12)
                                    .padding([.leading , .trailing] , 24)
                                    .background(AppTheme.colors.primary.color)
                                    .font(AppTheme.fonts.textMedium.font)
                                    .foregroundColor(AppTheme.colors.offWhite.color)
                                    .clipShape(BubbleArrow(rectCorner: rectCorner))
                                    .lineSpacing(10)
                                Spacer()
//                                Text(dateTime())
//                                    .font(AppTheme.fonts.textXSmall.font)
//                                    .padding(.top, 5)
//                                    .foregroundColor(AppTheme.colors.gray3.color)
                            }
                        }
                        
                    }
                } else {
                    HStack(alignment: .firstTextBaseline){
                        Text(stringValue())
                            .padding([.top , .bottom], 12)
                            .padding([.leading , .trailing] , 24)
                            .background(AppTheme.colors.primary.color)
                            .font(AppTheme.fonts.textMedium.font)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                            .clipShape(BubbleArrow(rectCorner: rectCorner))
                            .lineSpacing(10)
                        Spacer()
                        Text(dateTime())
                            .font(AppTheme.fonts.textXSmall.font)
                            .padding(.top, 5)
                            .foregroundColor(AppTheme.colors.gray3.color)
                    }
                }


                // profile Image...
//                Image(systemName: "person.circle.fill")
//                    .resizable()
//                    .frame(width: 30, height: 30)
//                    .clipShape(Circle())
                
//                VStack(alignment: .leading) {
//                    if let username = self.userName {
//                        // Show Time
//                        Text(username)
//                            .font(.body)
//                            .padding(.top, 5)
////                            .foregroundColor(Color.black)
//                    }
//                    if msg.photo == nil{
//                        if isGroup {
//                            Text(msg.fromDisplayName)
//                                .fontWeight(.regular)
//                                .font(Font.system(size: 10))
//                                .foregroundColor(Color.gray.opacity(0.4))
//                        }
//                        Text(stringValue())
//                            .padding(.all, 8)
//                            .background(Color(UIColor.secondarySystemBackground))
//                            .clipShape(BubbleArrow(myMsg: msg.myMsg))
//                    }
//                    else {
//                        Image(uiImage: UIImage(data: msg.photo!)!)
//                            .resizable()
//                            .frame(width: UIScreen.main.bounds.width - 150, height: 150)
//                            .clipShape(BubbleArrow(myMsg: msg.myMsg))
//                    }
//
//                    // Show Time
//                    Text(dateTime())
//                        .font(.caption)
//                        .padding(.top, 5)
//                        .foregroundColor(Color.gray.opacity(0.4))
//                }
//                Spacer(minLength: 25)
            }
        }
        .id(msg.id)
    }
    
    private func dateTime() -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(msg.createdAt/1000))
        let formatDate = DateFormatter()
        formatDate.dateFormat = "EEE HH:mm"
        return formatDate.string(from: date as Date)
    }
    
    private func stringValue() -> String {
        let str = String(data: msg.message, encoding: .utf8) ?? "x"
        return str
    }
}

struct BubbleArrow : Shape {
    var rectCorner: UIRectCorner
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 32, height: 32))
        return Path(path.cgPath)
    }
}
