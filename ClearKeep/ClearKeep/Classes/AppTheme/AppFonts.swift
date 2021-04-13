//
//  AppFonts.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 13/04/2021.
//

import UIKit

protocol AppFonts {
    
    func defaultFont(ofSize size: CGFloat) -> UIFont
    func defaultFont(ofSize size: CGFloat, weight: UIFont.Weight?) -> UIFont
    func customFont(font: String, size: CGFloat) -> UIFont

    var textLarge: UIFont { get }
    var textMedium: UIFont { get }
    var textSmall: UIFont { get }
    var textXSmall: UIFont { get }
    
    var linkLarge: UIFont { get }
    var linkMedium: UIFont { get }
    var linkSmall: UIFont { get }
    var linkXSmall: UIFont { get }
    
    var displayLarge: UIFont { get }
    var displayMedium: UIFont { get }
    var displaySmall: UIFont { get }

    var displayLargeBold: UIFont { get }
    var displayMediumBold: UIFont { get }
    var displaySmallBold: UIFont { get }
}
