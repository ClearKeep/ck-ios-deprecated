//
//  GradientBackground.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/12/21.
//

import SwiftUI

struct GradientBackground: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(gradient: Gradient(colors: [AppTheme.colors.gradientPrimaryDark.color, AppTheme.colors.gradientPrimaryLight.color]), startPoint: .leading, endPoint: .trailing)
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity,
                       alignment: .topLeading
                )
                //.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                
            
            content
                .edgesIgnoringSafeArea(.all)
        }.edgesIgnoringSafeArea(.all)
    }
}

extension View {
    func grandientBackground() -> some View {
        self.modifier(GradientBackground())
    }
    
    func gradientHeader() -> some View{
        ZStack(alignment: .center) {
            self.background(LinearGradient(gradient: Gradient(colors: [AppTheme.colors.gradientPrimaryDark.color, AppTheme.colors.gradientPrimaryLight.color]), startPoint: .leading, endPoint: .trailing))
        }
    }
}
