//
//  ViewExtensions.swift
//  ClearKeep
//
//  Created by Seoul on 2/25/21.
//

import Foundation
import UIKit
import SwiftUI
import Combine

extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

struct KeyboardManagment: ViewModifier {
    @State private var offset: CGFloat = 0
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .onAppear {
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                        withAnimation(Animation.easeOut(duration: 0.5)) {
                            
                            NotificationCenter.default.post(name: NSNotification.keyBoardWillShow,
                                                            object: nil,
                                                            userInfo: nil)
                            
                            if #available(iOS 14.0, *) {
                                offset = 0
                            } else {
                                offset = keyboardFrame.height - geo.safeAreaInsets.bottom
                            }
                        }
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                        withAnimation(Animation.easeOut(duration: 0.1)) {
                            offset = 0
                        }
                    }
                }
                .padding(.bottom, offset)
        }
    }
}
extension View {
    
    func keyboardManagment() -> some View {
        return self.modifier(KeyboardManagment())
    }
}

