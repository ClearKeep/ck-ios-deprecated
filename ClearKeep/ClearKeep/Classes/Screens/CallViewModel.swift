//
//  CallViewModel.swift
//  ClearKeep
//
//  Created by VietAnh on 1/4/21.
//

import Foundation
import WebRTC

enum CallStatus {
    case ringing
    case calling
    case endCall
}

class CallViewModel: NSObject, ObservableObject {
    @Published var localVideoView: RTCEAGLVideoView?
    @Published var remoteVideoView: RTCEAGLVideoView?
    @Published var remotesVideoView = [RTCEAGLVideoView]()
    @Published var receiveCameraOff = false
    @Published var cameraFront = false
    @Published var microEnable = true
    @Published var callStatus: CallStatus = .ringing
    @Published var callGroup = false
    
    let videoRoom = JanusVideoRoom.shared(withServer: URL(string: "ws://172.16.1.214:8188/janus")!)
    
    override init() {
        super.init()
        videoRoom.delegate = self
        let localConfig = JanusPublishMediaConstraints()
        localConfig.pushSize = CGSize(width: 720, height: 960)
        localConfig.fps = 16
        localConfig.videoBitrate = 600*1000
        localConfig.audioBirate = 200*1000
        localConfig.frequency = 44100
        videoRoom.localConfig = localConfig
    }
    
    func joinRoom(roomId: Int = 1234) {
        videoRoom.joinRoom(withRoomId: roomId, username: "iOS") { [weak self](isSuccess, error) in
            debugPrint("join success: \(isSuccess), Error: \(error?.localizedDescription ?? "")")
            DispatchQueue.main.async {
                self?.localVideoView = self?.videoRoom.publisher?._localRenderView
            }
        }
    }
    
    func endCall() {
        videoRoom.leaveRoom(callback: nil)
    }
    
    func cameraSwipe(isFront: Bool = false) {
        cameraFront = isFront
    }
}

extension CallViewModel: JanusVideoRoomDelegate {
    func janusVideoRoom(janusRoom: JanusVideoRoom, didJoinRoomWithId clientId: Int) {
        
    }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, remoteLeaveWithID clientId: Int) {
        // Remove video view remote
        if let roleListen = janusRoom.remotes[clientId] {
            remotesVideoView.remove(at: remotesVideoView.firstIndex(of: roleListen.renderView)!)
        }
    }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, remoteUnPublishedWithUid clientId: Int) {
        // Remove video view remote
        if let roleListen = janusRoom.remotes[clientId] {
            remotesVideoView.remove(at: remotesVideoView.firstIndex(of: roleListen.renderView)!)
        }
    }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, firstFrameDecodeWithSize size: CGSize, uId: Int) {
        if let roleListen = janusRoom.remotes[uId] {
            remotesVideoView.append(roleListen.renderView)
        }
        callStatus = .calling
    }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, netBrokenWithID reason: RTCNetBrokenReason) {
        
    }
}
