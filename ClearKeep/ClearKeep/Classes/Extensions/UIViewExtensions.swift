//
//  UIViewExtensions.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/20/21.
//

import Foundation

extension UIScrollView {
    func scrollToBottom(animated: Bool = true) {
        if (self.contentSize.height < self.bounds.height) { return }
        DispatchQueue.main.async {
            let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.height + self.contentInset.bottom)
            self.setContentOffset(bottomOffset, animated: animated)
        }
    }
}
