//
//  CallViewModel.swift
//  ClearKeep
//
//  Created by VietAnh on 1/4/21.
//

import Foundation
import WebRTC

class CallViewModel: NSObject, ObservableObject {
    @Published var localVideoView: RTCMTLEAGLVideoView?
    @Published var remoteVideoView: RTCMTLEAGLVideoView?
    @Published var remotesVideoView = [RTCMTLEAGLVideoView]()
    
    @Published var cameraOn = true
    @Published var cameraFront = false
    @Published var microEnable = true
    @Published var speakerEnable = false
    @Published var callStatus: CallStatus = .answered// .calling
    @Published var callGroup = false
    @Published var timeCall = "1:15" //""
    @Published var remoteViewRenderSize: CGSize = CGSize.zero
    @Published var isVideoRequesting = false
    @Published var callType: Constants.CallType = .video// .audio
    
    enum RenderScaleMode {
        case scaleToFit
        case scaleToFill
    }
    
    var callBox: CallBox?
    var callTimer: Timer?
    lazy var timeCounter = TimeCounter()
    
    var timeoutTimer: Timer?
    var callInterval: Int = 0
    
    override init() {
        super.init()
    }
    
    func updateCallBox(callBox: CallBox) {
        self.callBox = callBox
        self.callType = callBox.type
        updateVideoView()

        self.callBox?.stateDidChange = { [weak self] in
            DispatchQueue.main.async {
                let boxStatus = self?.callBox!.status
                if boxStatus == .answered {
                    self?.startCallTimer()
                } else if self?.callStatus != .ringing, boxStatus == .ringing {
                    self?.startCallTimout()
                } else if boxStatus == .ended {
                    self?.stopCallTimer()
                    self?.stopTimeoutTimer()
                }
                self?.callStatus = (self?.callBox!.status)!
                self?.updateVideoView()
            }
        }
        
        self.callBox?.renderSizeChangeWithSize = { [weak self] (size, uId) in
            guard let self = self else {
                return
            }
            
            // Just support only call 1:1 for now
            self.remoteViewRenderSize = size
        }
        
        self.callBox?.membersInCallDidChange = { [weak self] in
            guard let self = self else {
                return
            }
            self.updateVideoView()
        }
    }
    
    func getStatusMessage() -> String {
        switch callStatus {
        case .calling:
            return "Calling..."
        case .ringing:
            return "Connecting..."
        case .ended:
            return "End call..."
        default:
            return ""
        }
    }
    
    func getUserName() -> String {
        return callBox?.clientName ?? "N/A" //""
    }
    
    func updateVideoView() {
        DispatchQueue.main.async {
            if self.localVideoView == nil {
                self.localVideoView = self.callBox?.videoRoom?.publisher?.videoRenderView
            }
            
            if let listener = self.callBox?.videoRoom?.remotes.values.first {
                self.remoteVideoView = listener.videoRenderView
            }
            
            if let isGroup = self.callBox?.isCallGroup {
                self.callGroup = isGroup
            }
            
            print("updateVideoView >>> number remotes: \(self.callBox?.videoRoom?.remotes.count ?? 0)")
            if let lstRemote = self.callBox?.videoRoom?.remotes.values {
                self.remotesVideoView.removeAll()
                if lstRemote.count > 2 {
                    if let localVideo = self.localVideoView {
                        self.remotesVideoView.append(localVideo)
                    }
                }
                lstRemote.forEach { (listener) in
                    self.remotesVideoView.append(listener.videoRenderView)
                }
            }
            
        }
    }
    
    func endCallAndDismiss() {
        endCall()
    }
    
    func endCall() {
        if let callBox = self.callBox {
            if !callBox.isCallGroup {
                Backend.shared.cancelRequestCall(callBox.clientId, callBox.roomId) { (result, error) in
                }
            }
            CallManager.shared.end(call: callBox)
        }
    }
    
    func cameraSwipeChange() {
        cameraFront = !cameraFront
        if let callBox = self.callBox {
            callBox.videoRoom?.publisher?.switchCameraPosition()
        }
    }
    
    func cameraChange() {
        cameraOn = !cameraOn
        if let callBox = self.callBox {
            if cameraOn {
                callBox.videoRoom?.publisher?.cameraOn()
            } else {
                callBox.videoRoom?.publisher?.cameraOff()
            }
        }
    }
    
    func speakerChange() {
        speakerEnable = !speakerEnable
        if let callBox = self.callBox {
            if speakerEnable {
                callBox.videoRoom?.publisher?.speakerOn()
            } else {
                callBox.videoRoom?.publisher?.speakerOff()
            }
        }
    }
    
    func microChange() {
        microEnable = !microEnable
        if let callBox = self.callBox {
            if microEnable {
                callBox.videoRoom?.publisher?.unmuteAudio()
            } else {
                callBox.videoRoom?.publisher?.muteAudio()
            }
        }
    }
    
    func getNewVideoViewFrame(videoViewFrame: CGRect, containerFrame: CGRect,_ renderScaleMode: RenderScaleMode = .scaleToFill) -> CGRect {
        
        if videoViewFrame == CGRect.zero {
            if containerFrame == CGRect.zero {
                return CGRect.zero
            }
            return containerFrame
        }
        
        var videoFrame = AVMakeRect(aspectRatio: videoViewFrame.size, insideRect: containerFrame)
        var scale: CGFloat
        switch renderScaleMode {
        case .scaleToFit:
            scale = videoFrame.size.aspectFitScale(in: containerFrame.size)
        default:
            scale = videoFrame.size.aspectFillScale(in: containerFrame.size)
        }
        
        videoFrame.size.width = videoFrame.size.width * CGFloat(scale)
        videoFrame.size.height = videoFrame.size.height * CGFloat(scale)
        
        let leadingPadding = (videoFrame.width - containerFrame.width)/2
        let topPadding = (videoFrame.height - containerFrame.height)/2

        videoFrame.origin = CGPoint.init(x: -leadingPadding, y: -topPadding)
        
        return videoFrame
    }
    
    func getRemoteVideoRenderSize(videoView: RTCEAGLVideoView) -> CGSize {
        if let renderSize = callBox?.videoRoom?.remotes.first(where: { $0.value.videoRenderView == videoView })?.value.renderSize {
            return renderSize
        }
        return CGSize.zero
    }
    
    private func startCallTimout() {
        // Check timeout for call
        timeoutTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(CallViewModel.checkCallTimeout), userInfo: nil, repeats: true)
        RunLoop.current.add(timeoutTimer!, forMode: .default)
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
        timeCall = timeNow
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
        if callInterval >= 60 && callTimer == nil {
//            if callControl.isIncoming {
//                CallManager.shared.reject()
//            } else {
//                CallManager.shared.hangup()
//            }
            endCall()
        }
    }
    
    func updateCallTypeVideo() {
        guard let callBox = self.callBox else { return }
        Backend.shared.updateVideoCall(callBox.roomId, callType: .video) { [weak self](response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.callType = .video
                    self.callBox?.type = .video
                    self.callBox?.videoRoom?.publisher?.cameraOn()
                }
            }
        }
    }
    
    func didReceiveMessageGroup(userInfo: [AnyHashable : Any]?) {
        if let userInfo = userInfo,
           let publication = userInfo["publication"] as? Notification_NotifyObjectResponse {
            if publication.notifyType == "audio" ||  publication.notifyType == "video" {
                if publication.notifyType == "video" {
                    DispatchQueue.main.async {
                        self.callType = .video
                        self.callBox?.type = .video
                        self.callBox?.videoRoom?.publisher?.cameraOn()
                    }
                }
                // TODO: Check audio type update
            }
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
