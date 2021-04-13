//
//  GradientBackground.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/12/21.
//

import SwiftUI

struct GradientBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            LinearGradient(gradient: Gradient(colors: [AppTheme.colors.gradientPrimaryDark.color, AppTheme.colors.gradientPrimaryLight.color]), startPoint: .leading, endPoint: .trailing)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 40, alignment: .center)
                .edgesIgnoringSafeArea(.all)
            
            content
        }
    }
}

extension View {
    func grandientBackground() -> some View {
        self.modifier(GradientBackground())
    }
}
