//
//  RoundedButton.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/16/21.
//

import SwiftUI

enum RoundedButtonType {
    case gradient(type: GradientBackgroundType)
    case backgroundColorSuccess
    case backgroundColorError
    case backgroundColorWhite
    case border
}

struct RoundedButton: View {
    
    private var title: String
    private var fixedWidth: CGFloat?
    private var buttonType: RoundedButtonType
    private var action: VoidCompletion
    
    init(_ title: String, fixedWidth: CGFloat? = nil, buttonType: RoundedButtonType, action: @escaping VoidCompletion) {
        self.title = title
        self.action = action
        self.fixedWidth = fixedWidth
        self.buttonType = buttonType
    }
    
    private var buttonWidth: CGFloat {
        if let value = fixedWidth {
            return value
        } else {
            return .infinity
        }
    }
    
    private var titleColor: Color {
        switch buttonType {
        case .border: return AppTheme.colors.offWhite.color
        case .backgroundColorWhite: return AppTheme.colors.primary.color
        default: return AppTheme.colors.offWhite.color
        }
    }
    
    var body: some View {
        VStack {
            switch buttonType {
            case .border:
                buttonContent
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white, lineWidth: 2))
            default: buttonContent
            }
        }
    }
    
    var buttonContent: some View {
        Button(action: action) {
            ZStack(alignment: .center) {
                Group {
                    switch buttonType {
                    case .gradient(let gradientBackgroundType):
                        LinearGradient(gradient: Gradient(colors: [gradientBackgroundType.leadingColor, gradientBackgroundType.trailingColor]), startPoint: .leading, endPoint: .trailing)
                    case .backgroundColorSuccess:
                        AppTheme.colors.success.color
                    case .backgroundColorError:
                        AppTheme.colors.error.color
                    case .backgroundColorWhite:
                        AppTheme.colors.offWhite.color
                    default: EmptyView()
                    }
                    
                    
                    Text(title)
                        .font(AppTheme.fonts.linkSmall.font)
                        .foregroundColor(titleColor)
                        
                }
            }
        }
        .frame(width: buttonWidth)
        .frame(height: 40)
        .cornerRadius(20)
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            RoundedButton("Gradient Primary", fixedWidth: 200, buttonType: .gradient(type: .primary), action: {})

            RoundedButton("Gradient Secondary", fixedWidth: 200, buttonType: .gradient(type: .secondary), action: {})

            RoundedButton("Gradient Accent", fixedWidth: 200, buttonType: .gradient(type: .accent), action: {})

            RoundedButton("Background Success", fixedWidth: 200, buttonType: .backgroundColorSuccess, action: {})
            
            RoundedButton("Background Error", fixedWidth: 200, buttonType: .backgroundColorError, action: {})
        
            RoundedButton("Gradient Accent No Fixed Width", buttonType: .gradient(type: .accent), action: {})

            RoundedButton("Background Success No Fixed Width", buttonType: .backgroundColorSuccess, action: {})
            
            RoundedButton("Background Error No Fixed Width", buttonType: .backgroundColorError, action: {})
            
            VStack {
                RoundedButton("Background White", fixedWidth: 200, buttonType: .backgroundColorWhite, action: {})

                RoundedButton("Border", fixedWidth: 200, buttonType: .border, action: {})
            }
            .grandientBackground()
            
            Spacer()
       }
        .padding()
    }
}
