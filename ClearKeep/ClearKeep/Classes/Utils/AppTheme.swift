//
//  AppTheme.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/12/21.
//

import Foundation

enum AppTheme {}

extension AppTheme {
    
    enum Color {
        // Colors
        static let primary = UIColor(hex: "#6267FB")
        static let primaryDark = UIColor(hex: "#363BD0")
        static let primaryLight = UIColor(hex: "#898DFF")
        
        static let secondary = UIColor(hex: "#E06464")
        static let secondaryDark = UIColor(hex: "#D42B2B")
        static let secondaryLight = UIColor(hex: "#E99191")
        
        static let error = UIColor(hex: "#ED2E7E")
        static let errorDark = UIColor(hex: "#C30052")
        static let errorLight = UIColor(hex: "#FFE8F1")
        
        static let success = UIColor(hex: "#00BA88")
        static let successDark = UIColor(hex: "#00966D")
        static let successLight = UIColor(hex: "#DBFFF5")
        
        static let warning = UIColor(hex: "#F4B740")
        static let warningDark = UIColor(hex: "#946200")
        static let warningLight = UIColor(hex: "#FFD789")
        
        //static let gradientPrimary = UIColor(hex: "#")
        static let gradientPrimaryDark = UIColor(hex: "#7773F3")
        static let gradientPrimaryLight = UIColor(hex: "#8ABFF3")
        
        //static let gradientSecondary = UIColor(hex: "#")
        static let gradientSecondaryDark = UIColor(hex: "#363BD0")
        static let gradientSecondaryLight = UIColor(hex: "#64A1E0")
        
        //static let gradientAccent = UIColor(hex: "#")
        static let gradientAccentDark = UIColor(hex: "#E06464")
        static let gradientAccentLight = UIColor(hex: "#E99191")
        
        // Grayscale
        static let black = UIColor(hex: "#000000")
        static let gray1 = UIColor(hex: "#4E4B66")
        static let gray2 = UIColor(hex: "#6E7191")
        static let gray3 = UIColor(hex: "#A0A3BD")
        static let gray4 = UIColor(hex: "#D9DBE9")
        static let gray5 = UIColor(hex: "#EFF0F6")
        static let background = UIColor(hex: "#F7F7FC")
        static let offWhite = UIColor(hex: "#FCFCFC")
        
        // Text colors
        static let body = UIColor(hex: "#4E4B66")
        static let titleActive = UIColor(hex: "#14142B")
        static let label = UIColor(hex: "#6E7191")

    }
}
