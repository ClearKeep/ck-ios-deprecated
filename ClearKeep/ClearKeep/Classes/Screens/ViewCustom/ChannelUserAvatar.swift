//
//  ChannelUserAvatar.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/15/21.
//

import SwiftUI

enum UserOnlineStatus: Int {
    case active
    case away
    case doNotDisturb
    case invisible
    case none
}

enum GradientBackgroundType: Int {
    case primary
    case secondary
    case accent
    
    var leadingColor: Color {
        switch self {
        case .primary: return AppTheme.colors.gradientPrimaryDark.color
        case .secondary: return AppTheme.colors.gradientSecondaryDark.color
        case .accent: return AppTheme.colors.gradientAccentDark.color
        }
    }
    
    var trailingColor: Color {
        switch self {
        case .primary: return AppTheme.colors.gradientPrimaryLight.color
        case .secondary: return AppTheme.colors.gradientSecondaryLight.color
        case .accent: return AppTheme.colors.gradientAccentLight.color
        }
    }
}

struct ChannelUserAvatar: View {
    let status: UserOnlineStatus
    let text: String?
    let image: Image?
    
    let textColor: UIColor = .white
    var gradientBackgroundType: GradientBackgroundType = .primary
    
    var avatarSize: CGFloat = 64
    var statusSize: CGFloat = 16
    var font: Font = AppTheme.fonts.displaySmallBold.font
    
    init(avatarSize: CGFloat = 64, statusSize: CGFloat = 16, text: String?, font: Font = AppTheme.fonts.displaySmallBold.font, image: Image? = nil, status: UserOnlineStatus = .none, gradientBackgroundType: GradientBackgroundType = .accent) {
        self.avatarSize = avatarSize
        self.statusSize = statusSize
        self.text = text
        self.font = font
        self.image = image
        self.status = status
        self.gradientBackgroundType = gradientBackgroundType
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let loadedImage = image {
                    loadedImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: avatarSize, height: avatarSize, alignment: .center)
                } else {
                    ZStack(alignment: .center) {
                        LinearGradient(gradient: Gradient(colors: [gradientBackgroundType.leadingColor, gradientBackgroundType.trailingColor]), startPoint: .leading, endPoint: .trailing)
                            .frame(width: avatarSize, height: avatarSize, alignment: .center)
                        
                        Text(text?.prefixShortName() ?? "")
                            .font(font)
                            .frame(alignment: .center)
                            .foregroundColor(Color.primary)
                            .colorInvert()
                    }
                }
            }
            .clipShape(Circle())
            
            Group {
                switch status {
                case .active: AppTheme.colors.success.color
                case .away: AppTheme.colors.gray3.color
                case .doNotDisturb: AppTheme.colors.error.color
                case .invisible: AppTheme.colors.gray3.color
                case .none: Color.clear
                }
            }
            .frame(width: statusSize, height: statusSize)
            .clipShape(Circle())
        }
    }
}

struct ChannelUserAvatar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChannelUserAvatar(text: "Tommy", image: Image("ic_app"), status: .active)
            ChannelUserAvatar(text: "Vika", status: .away)
            ChannelUserAvatar(text: "Mum", status: .doNotDisturb)
            ChannelUserAvatar(text: "Mum", image: Image("ic_app"), status: .none)
            ChannelUserAvatar(text: "Only", status: .none, gradientBackgroundType: .primary)
        }
        .background(Color.white)
    }
}
