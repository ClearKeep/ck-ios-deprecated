//
//  AppTheme.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 13/04/2021.
//

import Foundation

class AppTheme: NSObject {
    static var fonts: AppFonts = DefaultFonts()
    static var colors: AppColors = DefaultColors()
    static let bundle: Bundle = Bundle(for: AppTheme.self)
    
    static func config(fonts: AppFonts, colors: AppColors) {
        AppTheme.fonts = fonts
        AppTheme.colors = colors
    }
}
