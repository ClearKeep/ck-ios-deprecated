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
    static let disableOpacityButton = 0.7
}

extension Constants {
    
    enum Mode {
        case development
        case stagging
        case production
        case debugServerLocal
        
        var grpc: String {
            switch self {
            case .development: return "54.235.68.160"
            case .stagging: return "54.235.68.160"
            case .production: return "54.235.68.160"
//            case .debugServerLocal: return "172.16.6.34"
            case .debugServerLocal: return "172.18.1.57"
            }
        }
        
        var grpc_port: Int {
            switch self {
            case .development: return 25000
            case .stagging: return 15000
            case .production: return 5000
//            case .debugServerLocal: return 25000
            case .debugServerLocal: return 15000
            }
        }

        var webrtc: String {
            switch self {
            case .development: return "ws://54.235.68.160:28188/janus"
            case .stagging: return "ws://54.235.68.160:18188/janus"
            case .production: return "ws://54.235.68.160:8188/janus"
            case .debugServerLocal: return "ws://172.16.6.34:28188/janus"
            }
        }
        
        var nameEnvironment: String {
            switch self {
            case .development: return "Development"
            case .stagging: return "Stagging"
            case .production: return "Production"
            case .debugServerLocal: return "LocalDebugServer"
            }
        }
    }
}

//development:
//grpc: 54.235.68.160:25000
//webrtc: ws://54.235.68.160:28188/janus
//
//stagging:
//grpc: 54.235.68.160:15000
//webrtc: ws://54.235.68.160:18188/janus
//
//production:
//grpc: 54.235.68.160:5000
//webrtc: ws://54.235.68.160:8188/janus
//
//debugServerLocal on Phuong's PC:
//grpc: 172.16.6.34:25000
//
