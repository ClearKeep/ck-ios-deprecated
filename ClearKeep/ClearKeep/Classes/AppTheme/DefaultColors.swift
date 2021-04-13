//
//  DefaultColors.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 13/04/2021.
//

import UIKit

struct DefaultColors: AppColors {
    
    var primary: UIColor
    var primaryDark: UIColor
    var primaryLight: UIColor
    
    var secondary: UIColor
    var secondaryDark: UIColor
    var secondaryLight: UIColor
    
    var error: UIColor
    var errorDark: UIColor
    var errorLight: UIColor
    
    var success: UIColor
    var successDark: UIColor
    var successLight: UIColor
    
    var warning: UIColor
    var warningDark: UIColor
    var warningLight: UIColor
    
    var gradientPrimaryDark: UIColor
    var gradientPrimaryLight: UIColor
    
    var gradientSecondaryDark: UIColor
    var gradientSecondaryLight: UIColor
    
    var gradientAccentDark: UIColor
    var gradientAccentLight: UIColor
    
    var black: UIColor
    var gray1: UIColor
    var gray2: UIColor
    var gray3: UIColor
    var gray4: UIColor
    var gray5: UIColor
    var background: UIColor
    var offWhite: UIColor
    
    var body: UIColor
    var titleActive: UIColor
    var label: UIColor
    
    init(
        primary: UIColor = UIColor(hex: "#6267FB"),
        primaryDark: UIColor = UIColor(hex: "#363BD0"),
        primaryLight: UIColor = UIColor(hex: "#898DFF"),
        
        secondary: UIColor = UIColor(hex: "#E06464"),
        secondaryDark: UIColor = UIColor(hex: "#D42B2B"),
        secondaryLight: UIColor = UIColor(hex: "#E99191"),
        
        error: UIColor = UIColor(hex: "#ED2E7E"),
        errorDark: UIColor = UIColor(hex: "#C30052"),
        errorLight: UIColor = UIColor(hex: "#FFE8F1"),
        
        success: UIColor = UIColor(hex: "#00BA88"),
        successDark: UIColor = UIColor(hex: "#00966D"),
        successLight: UIColor = UIColor(hex: "#DBFFF5"),
        
        warning: UIColor = UIColor(hex: "#F4B740"),
        warningDark: UIColor = UIColor(hex: "#946200"),
        warningLight: UIColor = UIColor(hex: "#FFD789"),
        
        gradientPrimaryDark: UIColor = UIColor(hex: "#7773F3"),
        gradientPrimaryLight: UIColor = UIColor(hex: "#8ABFF3"),
        
        gradientSecondaryDark: UIColor = UIColor(hex: "#363BD0"),
        gradientSecondaryLight: UIColor = UIColor(hex: "#64A1E0"),
        
        gradientAccentDark: UIColor = UIColor(hex: "#E06464"),
        gradientAccentLight: UIColor = UIColor(hex: "#E99191"),
        
        black: UIColor = UIColor(hex: "#000000"),
        gray1: UIColor = UIColor(hex: "#4E4B66"),
        gray2: UIColor = UIColor(hex: "#6E7191"),
        gray3: UIColor = UIColor(hex: "#A0A3BD"),
        gray4: UIColor = UIColor(hex: "#D9DBE9"),
        gray5: UIColor = UIColor(hex: "#EFF0F6"),
        background: UIColor = UIColor(hex: "#F7F7FC"),
        offWhite: UIColor = UIColor(hex: "#FCFCFC"),
        
        body: UIColor = UIColor(hex: "#4E4B66"),
        titleActive: UIColor = UIColor(hex: "#14142B"),
        label: UIColor = UIColor(hex: "#6E7191")
    ) {
        self.primary = primary
        self.primaryDark = primaryDark
        self.primaryLight = primaryLight
        
        self.secondary = secondary
        self.secondaryDark = secondaryDark
        self.secondaryLight = secondaryLight
        
        self.error = error
        self.errorDark = errorDark
        self.errorLight = errorLight
        
        self.success = success
        self.successDark = successDark
        self.successLight = successLight
        
        self.warning = warning
        self.warningDark = warningDark
        self.warningLight = warningLight
        
        self.gradientPrimaryDark = gradientPrimaryDark
        self.gradientPrimaryLight = gradientPrimaryLight
        
        self.gradientSecondaryDark = gradientSecondaryDark
        self.gradientSecondaryLight = gradientSecondaryLight
        
        self.gradientAccentDark = gradientAccentDark
        self.gradientAccentLight = gradientAccentLight
        
        self.black = black
        self.gray1 = gray1
        self.gray2 = gray2
        self.gray3 = gray3
        self.gray4 = gray4
        self.gray5 = gray5
        self.background = background
        self.offWhite = offWhite
        
        self.body = body
        self.titleActive = titleActive
        self.label = label
    }
}
