//
//  AppConfig.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/2/21.
//

import Foundation

enum AppConfig {

    #if DEVELOPMENT
    static let buildEnvironment: Constants.Mode = .development
    #elseif STAGING
    static let buildEnvironment: Constants.Mode = .stagging
    #else
    static let buildEnvironment: Constants.Mode = .production
    #endif

//    static let buildEnvironment: Constants.Mode = .debugServerLocal
}
