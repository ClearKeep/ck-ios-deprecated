//
//  KeyboardAdaptive.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/15/21.
//

import SwiftUI
import Combine

//extension Publishers {
//
//    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
//
//        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
//            .map { $0.keyboardHeight }
//        
//        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
//            .map { _ in CGFloat(0) }
//        
//        return MergeMany(willShow, willHide)
//            .eraseToAnyPublisher()
//    }
//}

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}
