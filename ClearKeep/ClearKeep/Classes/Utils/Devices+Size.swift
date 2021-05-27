//
//  Devices.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 27/05/2021.
//

import Foundation

extension Constants {
    
    enum Device {
        static let isSmallScreenSize = UIScreen.main.bounds.size.width < 350
    }
    
    enum Size {
        static let leftBannerWidth: CGFloat = Constants.Device.isSmallScreenSize ? 64 : 84
    }
}
