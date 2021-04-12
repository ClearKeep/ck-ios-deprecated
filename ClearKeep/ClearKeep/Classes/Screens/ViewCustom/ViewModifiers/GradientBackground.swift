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
            LinearGradient(gradient: Gradient(colors: [Color(Constants.Color.backgroundGradientLeading), Color(Constants.Color.backgroundGradientTrailing)]), startPoint: .leading, endPoint: .trailing)
                .frame(width: .infinity, height: .infinity, alignment: .center)
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
