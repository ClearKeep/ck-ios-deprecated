//
//  CallViewModel.swift
//  ClearKeep
//
//  Created by VietAnh on 1/4/21.
//

import Foundation
import WebRTC

class CallViewModel: NSObject, ObservableObject {
    @Published var localVideoView: RTCEAGLVideoView?
    @Published var remoteVideoView: RTCEAGLVideoView?
    @Published var remotesVideoView = [RTCEAGLVideoView]()
    
    @Published var receiveCameraOff = false
    @Published var cameraFront = false
    @Published var microEnable = true
    @Published var callStatus: CallStatus = .calling
    @Published var callGroup = false
    
    var callBox: CallBox?
    var callTimer: Timer?
    lazy var timeCounter = TimeCounter()
    
    var timeoutTimer: Timer?
    var callInterval: Int = 0
    
    override init() {
        super.init()
        
        // Check timeout for call
//        timeoutTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(CallViewModel.checkCallTimeout), userInfo: nil, repeats: true)
//        RunLoop.current.add(timeoutTimer!, forMode: .default)
    }
    
    func updateCallBox(callBox: CallBox) {
        self.callBox = callBox
        updateVideoView()

        self.callBox?.stateDidChange = { [weak self] in
            self?.callStatus = (self?.callBox!.status)!
            self?.updateVideoView()
        }
    }
    
    func updateVideoView() {
        DispatchQueue.main.async {
            self.localVideoView = self.callBox?.videoRoom?.publisher?.videoRenderView
            if let listener = self.callBox?.videoRoom?.remotes.values.first {
                self.remoteVideoView = listener.videoRenderView
            }
            debugPrint("localVideo is nil \(self.localVideoView == nil)")
        }
    }
    
    func endCallAndDismiss() {
        endCall()
    }
    
    func endCall() {
        if let callBox = self.callBox {
            CallManager.shared.end(call: callBox)
        }
    }
    
    func cameraSwipe(isFront: Bool = false) {
        cameraFront = isFront
    }
    
    private func startCallTimer() {
//        if callControl.signalingState != .answered || callControl.mediaState != .connected {
//            return
//        }
        
        if callTimer == nil {
            // Bắt đầu đếm giây
            callTimer = Timer(timeInterval: 1, target: self, selector: #selector(CallViewModel.timeTick(timer:)), userInfo: nil, repeats: true)
            RunLoop.current.add(callTimer!, forMode: .default)
            callTimer?.fire()
            
            // => Ko check timeout nữa
            self.stopTimeoutTimer()
        }
    }
    
    @objc private func timeTick(timer: Timer) {
        let timeNow = timeCounter.timeNow()
    }
    
    private func stopCallTimer() {
        CFRunLoopStop(CFRunLoopGetCurrent())
        callTimer?.invalidate()
        callTimer = nil
    }
    
    private func stopTimeoutTimer() {
        CFRunLoopStop(CFRunLoopGetCurrent())
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    @objc private func checkCallTimeout() {
        print("checkCallTimeout")
        callInterval += 10
        if callInterval > 60 && callTimer == nil {
//            if callControl.isIncoming {
//                CallManager.shared.reject()
//            } else {
//                CallManager.shared.hangup()
//            }
//            CallManager.shared.endCall()
        }
    }
}

//extension CallViewModel: JanusVideoRoomDelegate {
//    func janusVideoRoom(janusRoom: JanusVideoRoom, didJoinRoomWithId clientId: Int) {
//        callStatus = .ringing
//    }
//
//    func janusVideoRoom(janusRoom: JanusVideoRoom, remoteLeaveWithID clientId: Int) {
//        // Remove video view remote
//        if let roleListen = janusRoom.remotes[clientId] {
//            remotesVideoView.remove(at: remotesVideoView.firstIndex(of: roleListen.videoRenderView)!)
//        }
//        callStatus = .ended
//    }
//
//    func janusVideoRoom(janusRoom: JanusVideoRoom, remoteUnPublishedWithUid clientId: Int) {
//        // Remove video view remote
//        if let roleListen = janusRoom.remotes[clientId] {
//            remotesVideoView.remove(at: remotesVideoView.firstIndex(of: roleListen.videoRenderView)!)
//        }
//    }
//
//    func janusVideoRoom(janusRoom: JanusVideoRoom, firstFrameDecodeWithSize size: CGSize, uId: Int) {
//        if let roleListen = janusRoom.remotes[uId] {
//            remotesVideoView.append(roleListen.videoRenderView)
//        }
//        callStatus = .answered
//    }
//
//    func janusVideoRoom(janusRoom: JanusVideoRoom, netBrokenWithID reason: RTCNetBrokenReason) {
//
//    }
//}

class TimeCounter {
    var sec: Int = 0
    var min: Int = 0
    var hour: Int = 0
    
    func timeNow() -> String {
        sec = sec + 1
        if sec == 60 {
            sec = 0
            min = min + 1
        }
        
        if min == 60 {
            min = 0
            hour = hour + 1
        }
        
        return currentTime()
    }
    
    func currentTime() -> String {
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, min, sec)
        } else {
            return String(format: "%02d:%02d", min, sec)
        }
    }
    
    func hasStarted() -> Bool {
        if sec != 0 || min != 0 || hour != 0 {
            return true
        }
        
        return false
    }
    
    func reset() {
        sec = 0
        min = 0
        hour = 0
    }
}
