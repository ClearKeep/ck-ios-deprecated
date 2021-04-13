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
    
    var textFieldIconTint: UIColor
    
    init(
        primary: UIColor = #colorLiteral(red: 0.3835987449, green: 0.4038437307, blue: 0.9832308888, alpha: 1),// UIColor(hex: "#6267FB"),
        primaryDark: UIColor = #colorLiteral(red: 0.2133642435, green: 0.2326667011, blue: 0.8172033429, alpha: 1),// UIColor(hex: "#363BD0"),
        primaryLight: UIColor = #colorLiteral(red: 0.5383666158, green: 0.5527175069, blue: 1, alpha: 1),// UIColor(hex: "#898DFF"),
        
        secondary: UIColor = #colorLiteral(red: 0.8788725138, green: 0.3924512863, blue: 0.3940677047, alpha: 1),// UIColor(hex: "#E06464"),
        secondaryDark: UIColor = #colorLiteral(red: 0.8327288032, green: 0.1624940932, blue: 0.1665982008, alpha: 1),// UIColor(hex: "#D42B2B"),
        secondaryLight: UIColor = #colorLiteral(red: 0.9126839042, green: 0.5627285242, blue: 0.5630574226, alpha: 1),// UIColor(hex: "#E99191"),
        
        error: UIColor = #colorLiteral(red: 0.9275476336, green: 0.1823432744, blue: 0.4958347678, alpha: 1),// UIColor(hex: "#ED2E7E"),
        errorDark: UIColor = #colorLiteral(red: 0.7654986978, green: 0.0001034540401, blue: 0.3202075958, alpha: 1),// UIColor(hex: "#C30052"),
        errorLight: UIColor = #colorLiteral(red: 0.9980357289, green: 0.9088183045, blue: 0.9453745484, alpha: 1),// UIColor(hex: "#FFE8F1"),
        
        success: UIColor = #colorLiteral(red: 0, green: 0.7297249436, blue: 0.5331287384, alpha: 1),// UIColor(hex: "#00BA88"),
        successDark: UIColor = #colorLiteral(red: 0.001809648122, green: 0.5877657533, blue: 0.4280515313, alpha: 1),// UIColor(hex: "#00966D"),
        successLight: UIColor = #colorLiteral(red: 0.8587369323, green: 1, blue: 0.9605641961, alpha: 1),// UIColor(hex: "#DBFFF5"),
        
        warning: UIColor = #colorLiteral(red: 0.9587331414, green: 0.7176125646, blue: 0.250107795, alpha: 1),// UIColor(hex: "#F4B740"),
        warningDark: UIColor = #colorLiteral(red: 0.5808352232, green: 0.3825485706, blue: 0, alpha: 1),// UIColor(hex: "#946200"),
        warningLight: UIColor = #colorLiteral(red: 1, green: 0.8426898122, blue: 0.5372179747, alpha: 1),// UIColor(hex: "#FFD789"),
        
        gradientPrimaryDark: UIColor = #colorLiteral(red: 0.4681581855, green: 0.4513198733, blue: 0.9543935657, alpha: 1),// UIColor(hex: "#7773F3"),
        gradientPrimaryLight: UIColor = #colorLiteral(red: 0.5410716534, green: 0.7494730949, blue: 0.953292191, alpha: 1),// UIColor(hex: "#8ABFF3"),
        
        gradientSecondaryDark: UIColor = #colorLiteral(red: 0.2133642435, green: 0.2326667011, blue: 0.8172033429, alpha: 1),// UIColor(hex: "#363BD0"),
        gradientSecondaryLight: UIColor = #colorLiteral(red: 0.3936348557, green: 0.6305711269, blue: 0.8798473477, alpha: 1),// UIColor(hex: "#64A1E0"),
        
        gradientAccentDark: UIColor = #colorLiteral(red: 0.8788725138, green: 0.3924512863, blue: 0.3940677047, alpha: 1),// UIColor(hex: "#E06464"),
        gradientAccentLight: UIColor = #colorLiteral(red: 0.9126275778, green: 0.566683352, blue: 0.5670747161, alpha: 1),// UIColor(hex: "#E99191"),
        
        black: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),// UIColor(hex: "#000000"),
        gray1: UIColor = #colorLiteral(red: 0.3056983948, green: 0.2958287597, blue: 0.399384588, alpha: 1),// UIColor(hex: "#4E4B66"),
        gray2: UIColor = #colorLiteral(red: 0.4304504395, green: 0.4445848465, blue: 0.5689668655, alpha: 1),// UIColor(hex: "#6E7191"),
        gray3: UIColor = #colorLiteral(red: 0.626722157, green: 0.6372935176, blue: 0.7409598827, alpha: 1),// UIColor(hex: "#A0A3BD"),
        gray4: UIColor = #colorLiteral(red: 0.8505116105, green: 0.8579232097, blue: 0.9117991328, alpha: 1),// UIColor(hex: "#D9DBE9"),
        gray5: UIColor = #colorLiteral(red: 0.9369740486, green: 0.9408063293, blue: 0.9655880332, alpha: 1),// UIColor(hex: "#EFF0F6"),
        background: UIColor = #colorLiteral(red: 0.9684610963, green: 0.968318522, blue: 0.9889139533, alpha: 1),// UIColor(hex: "#F7F7FC"),
        offWhite: UIColor = #colorLiteral(red: 0.9881282449, green: 0.9882970452, blue: 0.988117516, alpha: 1),// UIColor(hex: "#FCFCFC"),
        
        body: UIColor = #colorLiteral(red: 0.3056983948, green: 0.2958287597, blue: 0.399384588, alpha: 1),// UIColor(hex: "#4E4B66"),
        titleActive: UIColor = #colorLiteral(red: 0.0780204162, green: 0.07602141052, blue: 0.1672900021, alpha: 1),// UIColor(hex: "#14142B"),
        label: UIColor = #colorLiteral(red: 0.4304504395, green: 0.4445848465, blue: 0.5689668655, alpha: 1), // UIColor(hex: "#6E7191")
        textFieldIconTint: UIColor  = #colorLiteral(red: 0.1737822592, green: 0.245875895, blue: 0.3166037202, alpha: 1) // UIColor(hex: "#2C3E50")
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
        
        self.textFieldIconTint = textFieldIconTint
    }
}
