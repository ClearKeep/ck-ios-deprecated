//
//  UIApplicationExtensions.swift
//  ClearKeep
//
//  Created by Hoa Pham on 12/03/2021.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
