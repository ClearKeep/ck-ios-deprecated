//
//  KeyboardHandler.swift
//  ClearKeep
//
//  Created by Seoul on 2/26/21.
//

import Combine
import SwiftUI

final class KeyboardHandler: ObservableObject {
    @Published private(set) var keyboardHeight: CGFloat = 0
    
    private var cancellable: AnyCancellable?
    
    private let keyboardWillShow = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillShowNotification)
        .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }
    
    private let keyboardWillHide = NotificationCenter.default
        .publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat.zero }
    
    init() {
        cancellable = Publishers.Merge(keyboardWillShow , keyboardWillHide)
            .subscribe(on: DispatchQueue.main)
            .assign(to: \.self.keyboardHeight, on: self)
    }
}
