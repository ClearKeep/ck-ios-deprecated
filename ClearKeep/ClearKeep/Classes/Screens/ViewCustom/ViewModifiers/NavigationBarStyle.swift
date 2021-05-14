//
//  NavigationBarStyle.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/19/21.
//

import SwiftUI

struct NavigationBarGradidentStyle<L,R>: ViewModifier where L: View, R: View {
    var title: String?
    var leftBarItems: (() -> L)?
    var rightBarItems: (() -> R)?
    
    func body(content: Content) -> some View {
        GeometryReader { reader in
            VStack(alignment: .leading) {
                Spacer()
                    .grandientBackground()
                    .frame(width: UIScreen.main.bounds.width, height: 20 + (reader.safeAreaInsets.top))
                
                VStack(alignment: .leading) {
                    HStack {
                        leftBarItems?()
                        Spacer()
                        rightBarItems?()
                    }
                    .padding(.top, 29)
                    
                    if let title = title {
                        Text(title)
                            .font(AppTheme.fonts.linkLarge.font)
                            .foregroundColor(AppTheme.colors.black.color)
                            .padding(.top, 23)
                    }
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
}

struct NavigationBarPlainStyle<L,R>: ViewModifier where L: View, R: View {
    var title: String
    var isGradientHeader: Bool = false
    var titleFont: Font
    var titleColor: Color
    var leftBarItems: (() -> L)?
    var rightBarItems: (() -> R)?
    
    func body(content: Content) -> some View {
        GeometryReader { reader in
            VStack(alignment: .leading) {
                HStack {
                    leftBarItems?()
                        .padding(.trailing, 8)
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(titleColor)
                    Spacer()
                    rightBarItems?()
                }
                .padding(.top, reader.safeAreaInsets.top)
                .padding(16)
                .if(isGradientHeader, transform: { view in
                    view.gradientHeader()
                })
                .frame(width: UIScreen.main.bounds.width, height: 60 + (reader.safeAreaInsets.top))
                content
            }
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct NavigationBarChatStyle<T>: ViewModifier where T: View {
    var titleView: (() -> T)
    var invokeBackButton: () -> ()
    var invokeCallButton: (Constants.CallType) -> ()
    
    func body(content: Content) -> some View {
        GeometryReader { reader in
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        invokeBackButton()
                    }, label: {
                        Image("ic_back")
                            .frame(width: 24, height: 24, alignment: .leading)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                    })
                    .padding(.trailing, 16)
                    titleView()
                    Spacer()
                    Button(action: {
                        invokeCallButton(.audio)
                    }, label: {
                        Image("ic_call")
                            .frame(width: 36, height: 36)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                    })
                    .padding(.trailing, 20)
                    Button(action: {
                        invokeCallButton(.video)
                    }, label: {
                        Image("ic_video_call")
                            .frame(width: 36, height: 36)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                    })
                }
                .padding(.top, reader.safeAreaInsets.top)
                .padding(16)
                .gradientHeader()
                .frame(width: UIScreen.main.bounds.width, height: 60 + (reader.safeAreaInsets.top))
                content
            }
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.top)
        }
        
    }
}

extension View {
    func applyNavigationBarGradidentStyle<L, R>(title: String? = nil, leftBarItems: @escaping (() -> L), rightBarItems: @escaping (() -> R)) -> some View where L: View, R: View {
        self.modifier(NavigationBarGradidentStyle(title: title, leftBarItems: leftBarItems, rightBarItems: rightBarItems))
    }
    
    func applyNavigationBarPlainStyleDark<L, R>(title: String, leftBarItems: @escaping (() -> L), rightBarItems: @escaping (() -> R)) -> some View where L: View, R: View {
        self.modifier(NavigationBarPlainStyle(title: title, titleFont: AppTheme.fonts.linkLarge.font, titleColor: AppTheme.colors.black.color, leftBarItems: leftBarItems, rightBarItems: rightBarItems))
    }
    
    func applyNavigationBarPlainStyleLight<L, R>(title: String, leftBarItems: @escaping (() -> L), rightBarItems: @escaping (() -> R)) -> some View where L: View, R: View {
        self.modifier(NavigationBarPlainStyle(title: title, isGradientHeader: true, titleFont: AppTheme.fonts.textMedium.font, titleColor: AppTheme.colors.offWhite.color, leftBarItems: leftBarItems, rightBarItems: rightBarItems))
    }
    
    func applyNavigationBarChatStyle<T>(titleView: @escaping (() -> T), invokeBackButton: @escaping (() -> ()), invokeCallButton: @escaping ((Constants.CallType) -> ())) -> some View where T: View {
        self.modifier(NavigationBarChatStyle(titleView: titleView, invokeBackButton: invokeBackButton, invokeCallButton: invokeCallButton))
    }
}
