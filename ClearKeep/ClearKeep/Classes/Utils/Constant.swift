//
//  Constant.swift
//  ClearKeep
//
//  Created by Seoul on 11/13/20.
//

import Foundation

struct Constants {
    static let keySaveUser = "keySaveUser"
    static let isChatRoom = "isChatRoom"
    static let isChatGroup = "isChatGroup"
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
            case .debugServerLocal: return "172.16.6.34"
            }
        }
        
        var grpc_port: Int {
            switch self {
            case .development: return 25000
            case .stagging: return 15000
            case .production: return 5000
            case .debugServerLocal: return 25000
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

extension Constants {
    
    enum Color {
        static let backgroundGradientLeading = UIColor(hex: "#7773F3")
        static let backgroundGradientTrailing = UIColor(hex: "#8ABFF3")
        
        static let primary = UIColor(hex: "#6267FB")
        static let gray5 = UIColor(hex: "#EFF0F6")

        static let errorLight = UIColor(hex: "#FFE8F1")
        static let errorBorder = UIColor(red: 0.929, green: 0.179, blue: 0.494, alpha: 1)
        
        static let buttonBorderLight = UIColor(red: 0.988, green: 0.988, blue: 0.988, alpha: 1)
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
