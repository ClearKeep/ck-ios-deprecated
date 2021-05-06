//
//  NavigationBarStyle.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/19/21.
//

import SwiftUI

struct NavigationBarStyle<L,R>: ViewModifier where L: View, R: View {
    var title: String
    var leftBarItems: (() -> L)?
    var rightBarItems: (() -> R)?
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            Spacer()
                .grandientBackground()
                .frame(width: UIScreen.main.bounds.width, height: 60)
            
            VStack(alignment: .leading) {
                HStack {
                    leftBarItems?()
                    Spacer()
                    rightBarItems?()
                }
                .padding(.top, 29)
                
                Text(title)
                    .font(AppTheme.fonts.linkLarge.font)
                    .foregroundColor(AppTheme.colors.black.color)
                    .padding(.top, 23)
            }
            .padding([.trailing , .leading , .bottom] , 16)
            
            content
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
}

struct NavigationBarChatStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .gradientHeader()
            .edgesIgnoringSafeArea(.top)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.14)
    }
}

extension View {
    func applyNavigationBarStyle<L, R>(title: String, leftBarItems: @escaping (() -> L), rightBarItems: @escaping (() -> R)) -> some View where L: View, R: View {
        self.modifier(NavigationBarStyle(title: title, leftBarItems: leftBarItems, rightBarItems: rightBarItems))
    }
    
    func applyNavigationBarChatStyle() -> some View {
        self.modifier(NavigationBarChatStyle())
    }
}
