//
//  TrackedCall.swift
//  ClearKeep
//
//  Created by VietAnh on 1/4/21.
//

import Foundation

class TrackedCall {
    var serial = 0
    var callId: String
    
    var receivedIncomingPush = false {
        willSet(newValue) {
            
        }
    }
    
    var receivedIncomingCall = false {
        willSet(newValue) {
            
        }
    }
    
    var ended = false
    
    init(id: String) {
        self.callId = id
    }
}
