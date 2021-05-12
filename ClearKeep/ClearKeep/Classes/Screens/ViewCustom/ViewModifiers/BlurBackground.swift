//
//  BlurBackground.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 12/05/2021.
//

import SwiftUI

struct BlurBackground: ViewModifier {
    let backgroundImage: Image?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topLeading) {
            Group {
                if let bgImage = backgroundImage {
                    bgImage
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 50)
                } else {
                    LinearGradient(gradient: Gradient(colors: [AppTheme.colors.gradientPrimaryDark.color, AppTheme.colors.gradientPrimaryLight.color]), startPoint: .leading, endPoint: .trailing)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

            content
                .edgesIgnoringSafeArea(.all)
        }.edgesIgnoringSafeArea(.all)
    }
}

extension View {
    func blurBackground(backgroundImage: Image?) -> some View {
        self.modifier(BlurBackground(backgroundImage: backgroundImage))
    }
}

