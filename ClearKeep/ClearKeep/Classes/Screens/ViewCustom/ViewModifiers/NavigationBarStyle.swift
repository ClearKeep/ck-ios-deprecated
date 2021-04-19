//
//  NavigationBarStyle.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/19/21.
//

import SwiftUI

struct NavigationBarStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .gradientHeader()
            .edgesIgnoringSafeArea(.all)
            .frame(width: UIScreen.main.bounds.width, height: 64)//UIScreen.main.bounds.height * 0.14)
    }
}

extension View {
    func applyNavigationBarStyle() -> some View {
        self.modifier(NavigationBarStyle())
    }
}
