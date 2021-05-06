//
//  View+Shake.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 5/5/21.
//

import SwiftUI

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

extension View {
    
    func shake(times: Int = 2) -> some View {
        self.modifier(Shake(animatableData: CGFloat(times)))
    }
}
