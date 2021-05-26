//
//  AppColors.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 13/04/2021.
//

import UIKit

protocol AppColors {
    
    var primary: UIColor { get }
    var primaryDark: UIColor { get }
    var primaryLight: UIColor { get }
    
    var secondary: UIColor { get }
    var secondaryDark: UIColor { get }
    var secondaryLight: UIColor { get }
    
    var error: UIColor { get }
    var errorDark: UIColor { get }
    var errorLight: UIColor { get }
    
    var success: UIColor { get }
    var successDark: UIColor { get }
    var successLight: UIColor { get }
    
    var warning: UIColor { get }
    var warningDark: UIColor { get }
    var warningLight: UIColor { get }
    
    var gradientPrimaryDark: UIColor { get }
    var gradientPrimaryLight: UIColor { get }
    
    var gradientSecondaryDark: UIColor { get }
    var gradientSecondaryLight: UIColor { get }
    
    var gradientAccentDark: UIColor { get }
    var gradientAccentLight: UIColor { get }
    
    var black: UIColor { get }
    var gray1: UIColor { get }
    var gray2: UIColor { get }
    var gray3: UIColor { get }
    var gray4: UIColor { get }
    var gray5: UIColor { get }
    var background: UIColor { get }
    var offWhite: UIColor { get }
    
    var body: UIColor { get }
    var titleActive: UIColor { get }
    var label: UIColor { get }
    
    var textFieldIconTint: UIColor { get }
    var shadow: UIColor { get }
}

