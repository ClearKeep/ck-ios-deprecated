//
//  CallModel.swift
//  ClearKeep
//
//  Created by VietAnh on 1/4/21.
//

import Foundation
import CallKit
import AVFoundation

class CallModel {
    var serial = 0
    var callId: String?
    var uuid: UUID?
    
    var answered = false
    var rejected = false
    
    var audioIsActived = false
    var isIncoming = false
    var answerAction: CXAnswerCallAction?
    
    var timer: Timer?
    var counter = 0
    
    init(isIncoming: Bool) {
        self.isIncoming = isIncoming
        if isIncoming {
            startTimer()
        }
    }
    
    private func startTimer() {
        if timer != nil { return }
        
        stopTimer()
        timer = Timer(timeInterval: 2, target: self, selector: #selector(CallModel.handleCallTimeOut), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .default)
        timer?.fire()
    }
    
    @objc private func handleCallTimeOut() {
        counter += 2
        
        if counter >= 28 {
            stopTimer()
            if !answered && !rejected {
                CallManager.shared.endCall()
            }
        }
    }
    
    private func stopTimer() {
        CFRunLoopStop(CFRunLoopGetCurrent())
        timer?.invalidate()
        timer = nil
    }
    
    func clean() {
        stopTimer()
    }
    
    deinit {
        stopTimer()
    }
}
