//
//  MenuDirectMessageRow.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/20/21.
//

import SwiftUI

struct MenuDirectMessageRow: View {
    let userName: String
    let image: Image?
    let status: UserOnlineStatus
    let newMessageNumber: Int
    let showLeftIcon: Bool
    
    // Use for Direct message row
    init(userName: String, image: Image?, status: UserOnlineStatus, newMessageNumber: Int) {
        self.userName = userName
        self.image = image
        self.status = status
        self.newMessageNumber = newMessageNumber
        self.showLeftIcon = true
    }
    
    // Use for group chat message row
    init(userName: String,newMessageNumber: Int) {
        self.userName = userName
        self.image = nil
        self.status = .none
        self.newMessageNumber = newMessageNumber
        self.showLeftIcon = false
    }
    
    var newMessageText: String {
        switch newMessageNumber {
        case 0: return ""
        case 1...9: return "\(newMessageNumber)"
        default: return "9+"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if showLeftIcon {
                ChannelUserAvatar(avatarSize: 24, statusSize: 8, text: userName, font: AppTheme.fonts.linkSmall.font, image: image, status: status, gradientBackgroundType: .accent)
            }
            Text(userName)
                .font(AppTheme.fonts.linkSmall.font)
                .foregroundColor(AppTheme.colors.gray2.color)
            
            Spacer()
            
            if !newMessageText.isEmpty {
                Text(newMessageText)
                    .font(AppTheme.fonts.textXSmall.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
                    .frame(width: 24, height: 24, alignment: .center)
                    .background(AppTheme.colors.secondary.color)
                    .clipShape(Circle())
                
            }
        }
        .padding(.horizontal, 8)
        .padding(.all, 8)
    }
}

struct MenuDirectMessageRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MenuDirectMessageRow(userName: "Group chat 1", newMessageNumber: 10)
            MenuDirectMessageRow(userName: "Group chat 2", newMessageNumber: 5)
            
            MenuDirectMessageRow(userName: "Active", image: nil, status: .active, newMessageNumber: 10)
            MenuDirectMessageRow(userName: "Do not disturb", image: nil, status: .doNotDisturb, newMessageNumber: 5)
            MenuDirectMessageRow(userName: "Away", image: nil, status: .away, newMessageNumber: 2)
            MenuDirectMessageRow(userName: "Invisible", image: nil, status: .invisible, newMessageNumber: 0)
            MenuDirectMessageRow(userName: "None", image: nil, status: .none, newMessageNumber: 0)
            
            Spacer()
        }
    }
}
