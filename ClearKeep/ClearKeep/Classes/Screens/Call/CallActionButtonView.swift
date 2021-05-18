//
//  CallActionButtonView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 18/05/2021.
//

import SwiftUI

struct CallActionButtonView: View {
    var onIcon: String
    var offIcon: String
    var isOn: Bool
    var activeForegroundColor: Color
    var activeBackgroundColor: Color
    var inactiveForegroundColor: Color
    var inactiveBackgroundColor: Color
    var title: String
    var action: VoidCompletion
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                action()
            }, label: {
                Image(isOn ? onIcon: offIcon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(isOn ? activeForegroundColor : inactiveForegroundColor)
                    .frame(width: 24, height: 24)
                    .padding(.all, 20)
                    .background(isOn ? activeBackgroundColor : inactiveBackgroundColor)
                    .cornerRadius(32)
                    .overlay(Circle().stroke(inactiveForegroundColor, lineWidth: isOn ? 0 : 2))
            })
            
            if !title.isEmpty {
                Text(title)
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
            }
        }
    }
}

extension CallActionButtonView {
    
    enum StyleButton {
        case video
        case voice
        case endCall
    }
    
    init(onIcon: String,
         offIcon: String,
         isOn: Bool,
         title: String = "",
         styleButton: StyleButton = .video,
         action: @escaping VoidCompletion) {
        self.onIcon = onIcon
        self.offIcon = offIcon
        self.isOn = isOn
        self.title = title
        self.action = action
        
        switch styleButton {
        case .video:
            self.activeForegroundColor = AppTheme.colors.offWhite.color
            self.activeBackgroundColor = AppTheme.colors.primary.color
            self.inactiveForegroundColor = AppTheme.colors.gray1.color
            self.inactiveBackgroundColor = AppTheme.colors.offWhite.color
        case .voice:
            self.activeForegroundColor = AppTheme.colors.gray1.color
            self.activeBackgroundColor = AppTheme.colors.offWhite.color
            self.inactiveForegroundColor = AppTheme.colors.offWhite.color
            self.inactiveBackgroundColor = Color.clear
        case .endCall:
            self.activeForegroundColor = AppTheme.colors.offWhite.color
            self.activeBackgroundColor = AppTheme.colors.error.color
            self.inactiveForegroundColor = AppTheme.colors.offWhite.color
            self.inactiveBackgroundColor = AppTheme.colors.error.color
        }
    }
}

struct CallActionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
        CallActionButtonView(onIcon: "Microphone",
                             offIcon: "Microphone-off",
                             isOn: true,
                             title: "Mute",
                             action: {})

        CallActionButtonView(onIcon: "Phone-off",
                             offIcon: "Phone-off",
                             isOn: true,
                             title: "Voice",
                             styleButton: .voice,
                             action: {})
        }
        .background(Color.green)
    }
}
