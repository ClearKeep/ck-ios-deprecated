//
//  IncomingCallFullScreenViewModel.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 12/05/2021.
//

import SwiftUI

class IncomingCallFullScreenViewModel: ObservableObject {
    
    let backgroundImage: Image?
    let avatar: Image?

    let callerName: String
    
    let isIncomingCall: Bool
    let isGroupCall: Bool
    let isVideoCall: Bool
    
    @Published var callingStatusText: String = ""
    @Published var timeString: String = ""
    
    init(backgroundImage: Image?,
         avatar: Image?,
         callerName: String,
         isIncomingCall: Bool,
         isGroupCall: Bool,
         isVideoCall: Bool)
    {
        self.backgroundImage = backgroundImage
        self.avatar = avatar
        self.callerName = callerName
        self.isIncomingCall = isIncomingCall
        self.isGroupCall = isGroupCall
        self.isVideoCall = isVideoCall
        
        if isGroupCall {
            if isVideoCall {
                callingStatusText = "Incoming Video Group Call"
            } else {
                callingStatusText = "Incoming Voice Group Call"
            }
        } else {
            if isVideoCall {
                callingStatusText = "Incoming Video Call"
            } else {
                callingStatusText = "Incoming Voice Call"
            }
        }
    }
}
