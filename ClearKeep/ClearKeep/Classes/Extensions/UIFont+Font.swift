//
//  UIFont+Font.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/14/21.
//

import SwiftUI

extension UIFont {
    
    var font: Font {
        return Font(self as CTFont)
    }
}
