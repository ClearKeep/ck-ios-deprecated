//
//  DefaultFonts.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 13/04/2021.
//

import UIKit

struct DefaultFonts: AppFonts {
    
    // MARK: - Fonts
    var textLarge: UIFont { return defaultFont(ofSize: 20, weight: .regular) }
    var textMedium: UIFont { return defaultFont(ofSize: 16, weight: .regular) }
    var textSmall: UIFont { return defaultFont(ofSize: 14, weight: .regular) }
    var textXSmall: UIFont { return defaultFont(ofSize: 12, weight: .regular) }
    
    var linkLarge: UIFont { return defaultFont(ofSize: 20, weight: .bold) }
    var linkMedium: UIFont { return defaultFont(ofSize: 16, weight: .bold) }
    var linkSmall: UIFont { return defaultFont(ofSize: 14, weight: .bold) }
    var linkXSmall: UIFont { return defaultFont(ofSize: 12, weight: .bold) }
    
    var displayLarge: UIFont { return defaultFont(ofSize: 48, weight: .regular) }
    var displayMedium: UIFont { return defaultFont(ofSize: 32, weight: .regular) }
    var displaySmall: UIFont { return defaultFont(ofSize: 24, weight: .regular) }
    
    var displayLargeBold: UIFont {
        if UIScreen.main.bounds.size.width < 350 {
            return defaultFont(ofSize: 40, weight: .bold)
        } else {
            return defaultFont(ofSize: 48, weight: .bold)
        }
    }
    var displayMediumBold: UIFont {
        if UIScreen.main.bounds.size.width < 350 {
            return defaultFont(ofSize: 30, weight: .bold)
        } else {
            return defaultFont(ofSize: 32, weight: .bold)
        }
    }
    var displaySmallBold: UIFont {
        if UIScreen.main.bounds.size.width < 350 {
            return defaultFont(ofSize: 22, weight: .bold)
        } else {
            return defaultFont(ofSize: 24, weight: .bold)
        }
    }
    
    
    // Methods
    init() {}

    func defaultFont(ofSize size: CGFloat) -> UIFont {
        return defaultFont(ofSize: size, weight: nil)
    }

    func defaultFont(ofSize size: CGFloat, weight: UIFont.Weight? = nil) -> UIFont {
        if let weight = weight {
            let font: UIFont?
            switch weight {
            case .bold:
                font = UIFont(name: "SF-Pro-Text-Bold", size: size)
            case .semibold, .medium:
                font = UIFont(name: "SF-Pro-Text-Medium", size: size)
            case .thin, .light:
                font = UIFont(name: "SF-Pro-Text-Light", size: size)
            default:
                font = UIFont(name: "SF-Pro-Text-Regular", size: size)
            }
            return font ?? .systemFont(ofSize: size, weight: weight)
        } else {
            return UIFont(name: "SF-Pro-Text-Regular", size: size) ?? .systemFont(ofSize: size)
        }
    }

    func customFont(font: String, size: CGFloat) -> UIFont {
        return UIFont(name: font, size: size) ?? self.defaultFont(ofSize: size)
    }

    /**
     * Returns a factor representing the scale to resize some fonts for accesibility.
     */
    var fontScale: CGFloat {
        let scale = UIFont.preferredFont(forTextStyle: .body).pointSize / 17.0
        return scale > 1 ? scale : 1.0 // Only scale it up, never down.
    }
}

