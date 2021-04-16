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
    @Binding var status: UserOnlineStatus
    @Binding var text: String?
    @Binding var image: Image?
    
    let textColor: UIColor = .white
    var gradientBackgroundType: GradientBackgroundType = .primary
    
    let avatarSize: CGFloat = 64
    let statusSize: CGFloat = 16
    let font: Font = AppTheme.fonts.displaySmallBold.font
    
    init(text: Binding<String?>, image: Binding<Image?> = .constant(nil), status: Binding<UserOnlineStatus> = .constant(UserOnlineStatus.none), gradientBackgroundType: GradientBackgroundType = .accent) {
        self._text = text
        self._image = image
        self._status = status
        self.gradientBackgroundType = gradientBackgroundType
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
        
        .background(Color.white)
    }
}

struct ChannelUserAvatar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChannelUserAvatar(text: .constant("Tommy"), image: .constant(Image("ic_app")), status: .constant(.active))
            ChannelUserAvatar(text: .constant("Vika"), status: .constant(.away))
            ChannelUserAvatar(text: .constant("Mum"), status: .constant(.doNotDisturb))
            ChannelUserAvatar(text: .constant("Mum"), image: .constant(Image("ic_app")), status: .constant(.none))
            ChannelUserAvatar(text: .constant("Only"), status: .constant(.none), gradientBackgroundType: .primary)
        }
    }
}
