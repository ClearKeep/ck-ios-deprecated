//
//  Constant.swift
//  ClearKeep
//
//  Created by Seoul on 11/13/20.
//

import Foundation

struct Debug {
   
   /// Print information
   /// - Parameters:
   ///   - message: Message of log
   ///   - object: Object to log
   ///   - function: Function's name
   ///   - line: Line number of function
   static func DLog(_ message: String, _ object: Any? = "", function: String = #function, line: Int = #line) {
      #if DEBUG
      print("- [", function, "] - [ LINE", line, "] -", message, object as Any)
      #endif
   }
}

struct SharedDataAppGroup {
    static private let kAppGroupName = "group.telred.clearkeep3.ios.staging"
    static let sharedUserDefaults = UserDefaults(suiteName: kAppGroupName)
    
    static func sharedDirectoryPath() -> String? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: kAppGroupName)?.path
    }
    
    static func sharedDatabasePath(database: String) -> URL? {
        let sharedDirectoryURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: kAppGroupName)
        return sharedDirectoryURL?.appendingPathComponent(database)
    }
    
    static var database: YapDatabase?
}

struct Constants {
    static let groupIdTemp = Int64(0)
    static let encryptedDeviceId =  Int32(555)
    static let decryptedDeviceId = Int32(444)
    static let keySaveUser = "keySaveUser"
    static let keySaveTokenPushNotify = "keySaveTokenPushNotify"
    static let keySaveTokenPushNotifyAPNS = "keySaveTokenPushNotifyAPNS"
    static let keySaveTurnServerUser = "keySaveTurnServerUser"
    static let keySaveTurnServerPWD = "keySaveTurnServerPWD"
    static let keySaveUserID = "keySaveUserID"
    static let keySaveRefreshToken = "keySaveRefreshToken"
    
    static let keyChainService = "keyChainService"
    static let keyChainUUID = "keyChainUUID"
    static let userDefaultUUID = "userDefaultUUID"
    
    static let keySaveUsers = "keySaveUsers"
    static let keySaveRefreshTokens = "keySaveRefreshTokens"
    
    struct User {
        static let loginDate = "loginDateTime"
    }
    
    enum CallType: String {
        case audio
        case video
    }

    static let googleSignInClientId = "1092685949059-gfkapttahq1tuagf85lk3osr3d5i0bsg.apps.googleusercontent.com"
}

extension Constants {
    static let disableButtonOpacity = 0.7
}

extension Constants {
    
    enum Mode {
        case development
        case stagging
        case production
        case debugServerLocal
    }
}

