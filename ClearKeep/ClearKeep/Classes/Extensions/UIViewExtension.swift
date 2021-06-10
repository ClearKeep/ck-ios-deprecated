//
//  UIViewExtension.swift
//  ClearKeep
//
//  Created by Nguyễn Nam on 5/24/21.
//

import Foundation
import SwiftUI

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)

    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

extension UIViewController {
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, @ViewBuilder builder: () -> Content, completion: (() ->())? = nil) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "dismissModal"), object: nil, queue: nil) { [weak toPresent] _ in
            toPresent?.dismiss(animated: true, completion: nil)
        }
        self.present(toPresent, animated: true, completion: completion)
    }
}

extension UIScrollView {
    func scrollToBottom(animated: Bool = true) {
        DispatchQueue.main.async {
            if (self.contentSize.height < self.bounds.height) { return }
            let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.height + self.contentInset.bottom)
            self.setContentOffset(bottomOffset, animated: animated)
        }
    }
}
