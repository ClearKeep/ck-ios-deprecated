//
//  PlainColorBackground.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/27/21.
//

import SwiftUI

struct PlainColorBackground: ViewModifier {
    
    let color: Color
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            color
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: .infinity,
                       alignment: .topLeading
                )
                
            
            content
                .edgesIgnoringSafeArea(.all)
        }.edgesIgnoringSafeArea(.all)
    }
}

extension View {
    func plainColorBackground(color: Color) -> some View {
        self.modifier(PlainColorBackground(color: color))
    }
}
