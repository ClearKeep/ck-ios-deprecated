//
//  OutgoingCallViewModel.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 5/17/21.
//

import SwiftUI

class OutgoingCallViewModel: ObservableObject {
    
    let backgroundImage: Image?
    let avatar: Image?

    let callerName: String
    
    let isGroupCall: Bool
    let isVideoCall: Bool

    var endCallButtonTapCompletion: VoidCompletion? = nil
    
    @Published var callingStatusText: String = ""
    @Published var timeString: String = ""
    @Published var isCallConnected: Bool = false
    
    init(backgroundImage: Image?,
         avatar: Image?,
         callerName: String,
         isGroupCall: Bool,
         isVideoCall: Bool)
    {
        self.backgroundImage = backgroundImage
        self.avatar = avatar
        self.callerName = callerName
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

