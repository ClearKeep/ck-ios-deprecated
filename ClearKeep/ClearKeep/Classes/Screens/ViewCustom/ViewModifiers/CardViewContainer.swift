//
//  CardViewContainer.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/14/21.
//

import SwiftUI

struct CardViewContainer: ViewModifier {
    let level: Int
    let showShadow: Bool

    var borderColor: Color {
        switch level {
        case 1: return AppTheme.colors.gray2.color
        case 2: return AppTheme.colors.gray3.color
        case 3: return AppTheme.colors.gray4.color
        default: return AppTheme.colors.gray4.color
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .clipShape(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
            )
            .shadow(color: borderColor, radius: showShadow ? 3 : 0, x: 0, y: showShadow ? 3 : 0)
    }
}

extension View {
    func embededInCardView(level: Int = 3, showShadow: Bool = false) -> some View {
        self.modifier(CardViewContainer(level: level, showShadow: showShadow))
    }
}
