//
//  UIColor+Hex.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/12/21.
//

import Foundation
import SwiftUI

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        assert(hexFormatted.count == 6, "Invalid hex code used.")

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }

    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
    var color: Color {
        return Color(self)
    }
}



extension UIColor {
    static func random() -> UIColor {
        let listColor = [AppTheme.colors.successDark ,
                         AppTheme.colors.primaryDark ,
                         AppTheme.colors.secondaryDark ,
                         AppTheme.colors.errorDark ,
                         AppTheme.colors.warningDark ,
                         AppTheme.colors.gradientPrimaryDark ,
                         AppTheme.colors.gradientAccentDark]
        
        return listColor.randomElement()!
    }
}

