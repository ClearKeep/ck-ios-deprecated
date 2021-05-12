//
//  TopBanner.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 12/05/2021.
//

import SwiftUI

struct TopBanner<T>: ViewModifier where T: View {
    @Binding var show: Bool
    var autoDismiss: Bool
    var contentView: (() -> T)?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if show {
                VStack {
                    HStack {
                        contentView?()
                    }
                    
                    Spacer()
                }
                .padding()
                .padding(.top, 44)
                .animation(.easeInOut)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        self.show = false
                    }
                }
                .onAppear(perform: {
                    if autoDismiss {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                self.show = false
                            }
                        }
                    }
                })
            }
        }
    }
}

extension View {
    func showTopBanner<T>(show: Binding<Bool>, autoDismiss: Bool, contentView: @escaping (() -> T)) -> some View where T: View {
        self.modifier(TopBanner(show: show, autoDismiss: autoDismiss, contentView: contentView))
    }
}

