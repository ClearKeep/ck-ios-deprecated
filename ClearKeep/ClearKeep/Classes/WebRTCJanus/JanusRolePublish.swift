//
//  JanusRolePublish.swift
//  JanusWebRTC
//
//  Created by Nguyen Luan on 12/19/20.
//  Copyright © 2020 Vmodev. All rights reserved.
//

import UIKit
import WebRTC

protocol JanusRolePublishDelegate {
    func JanusRolePublish(role: JanusRolePublish, didReceiveVideoView videoView: RTCEAGLVideoView)
}

class JanusRolePublish: JanusRole {
    
    private var localAudioTrack: RTCAudioTrack!
    private var localRenderView: RTCEAGLVideoView?
    private var channels: (video: Bool, audio: Bool, datachannel: Bool) = (false, false, false)
    private var customFrameCapturer: Bool = false
    var _localRenderView: RTCEAGLVideoView?
    var localVideoTrack: RTCVideoTrack!
    var cameraDevicePosition: AVCaptureDevice.Position = .front
    var videoCapturer: RTCVideoCapturer!
    let rtcAudioSession =  RTCAudioSession.sharedInstance()
    let audioQueue = DispatchQueue(label: "audio")
    
    override init(withJanus janus: Janus, delegate: JanusRoleDelegate? = nil) {
        super.init(withJanus: janus, delegate: delegate)
        self.pType = .publish
    }
    
    override class func role(withDict dict: [String : Any], janus: Janus, delegate: JanusRoleDelegate?) -> JanusRole {
        let publish = JanusRolePublish(withJanus: janus, delegate: delegate)
        if let username = dict["display"] as? String,
            let videoCode = dict["video_codec"] as? String,
            let id = dict["id"] as? Int {
            publish.id = id
            publish.display = username
            publish.audioCode = dict["audio_codec"] as? String
            publish.videoCode = videoCode
        }
        return publish
    }
    
    func startPreview() {
//        cameraPreview.captureSession.startRunning()
    }
    
    func stopPreview() {
//        cameraPreview.captureSession.stopRunning()
    }
    
    func setup(customFrameCapturer: Bool = true) {
        channels.video = true
        channels.audio = true
        self.customFrameCapturer = customFrameCapturer
        
        localRenderView = RTCEAGLVideoView()
        localRenderView!.delegate = self
        
        setupLocalTracks()
        
        configureAudioSession()
        
        if self.channels.video {
            startCaptureLocalVideo(cameraPositon: self.cameraDevicePosition, videoWidth: 640, videoHeight: 640*16/9, videoFps: 30)
            self.localVideoTrack?.add(self.localRenderView!)
        }
        if let delegatePublish = self.delegate as? JanusRolePublishDelegate {
            delegatePublish.JanusRolePublish(role: self, didReceiveVideoView: localRenderView!)
        }
    }

    func setupLocalViewFrame(frame: CGRect) {
        localRenderView?.frame = frame
    }
    
    func captureCurrentFrame(sampleBuffer: CMSampleBuffer){
        if let capturer = self.videoCapturer as? RTCCustomFrameCapturer {
            capturer.capture(sampleBuffer)
        }
    }
    
    func captureCurrentFrame(sampleBuffer: CVPixelBuffer){
        if let capturer = self.videoCapturer as? RTCCustomFrameCapturer {
            capturer.capture(sampleBuffer)
        }
    }
    
    // MARK: - Override function
    override func joinRoom(withRoomId roomId: Int, username: String?, callback: @escaping RoleJoinRoomCallback) {
        if !self.attached {
            self.attach { [weak self](error) in
                if let error = error {
                    callback(error)
                } else {
                    if let self = self {
                        self.joinRoom(withRoomId: roomId, username: username) { (error) in
                            callback(error)
                        }
                    } else {
                        callback(JanusResultError.codeErr(code: -1, desc: "Publish attach error"))
                    }
                }
            }
            return
        }
        
        if self.channels.video {
            self.peerConnection.add(localVideoTrack, streamIds: ["stream0"])
        }
        if self.channels.audio {
            self.peerConnection.add(localAudioTrack, streamIds: ["stream0"])
        }
                
        super.joinRoom(withRoomId: roomId, username: username) { [weak self](error) in
            if error == nil {
                self?.sendOffer()
            }
            callback(error)
        }
    }
    
    override func leaveRoom(callback: @escaping RoleLeaveRoomCallback) {
//        super.leaveRoom {
//            callback()
//        }
        self.detach {
            callback()
        }
    }
    
    override func handleRemote(jsep: [String: Any]) {
        guard let sdp = jsep["sdp"] as? String else { return }
        var sdpType: RTCSdpType = .answer
        if let type = jsep["type"] as? String, type == "offer" {
            sdpType = .offer
        }
        let sessionDest = RTCSessionDescription(type: sdpType, sdp: sdp)
        self.peerConnection.setRemoteDescription(sessionDest) { (error) in
            if let error = error {
                debugPrint("Publish Role setRemoteDescription error: \(String(describing: error.localizedDescription))")
            }
        }
    }
    
    override func pluginHandle(message msg: [String : Any], jsep: [String : Any]?, transaction: String?) {
        guard let event = msg["videoroom"] as? String else { return }
        if event == "event" {
            if let publishers = msg["publishers"] as? [[String: Any]] {
                for item in publishers {
                    if let delegate = self.delegate as? JanusRoleListenDelegate {
                        let listener = JanusRoleListen.role(withDict: item, janus: self.janus, delegate: delegate)
                        listener.privateId = self.privateId
                        listener.opaqueId = self.opaqueId
                        delegate.janusRole(role: self, didJoinRemoteRole: listener)
                    }
                }
            } else if let leaving = msg["leaving"] as? Int {
                if let delegate = self.delegate as? JanusRoleListenDelegate {
                    delegate.janusRole(role: self, didLeaveRemoteRoleWithUid: leaving)
                }
            } else if let unpublished = msg["unpublished"] as? Int {
                if let delegate = self.delegate as? JanusRoleListenDelegate {
                    delegate.janusRole(role: self, remoteUnPublishedWithUid: unpublished)
                }
            }
        }
    }
    
    // MARK: Private function
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func setupLocalTracks() {
        if self.channels.video == true {
            self.localVideoTrack = createVideoTrack()
        }
        if self.channels.audio == true {
            self.localAudioTrack = createAudioTrack()
        }
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioSource = RTCFactory.shared.peerConnectionFactory().audioSource(with: self.mediaConstraints?.getAudioConstraints())
        let audioTrack = RTCFactory.shared.peerConnectionFactory().audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = RTCFactory.shared.peerConnectionFactory().videoSource()
        
        if self.customFrameCapturer {
            self.videoCapturer = RTCCustomFrameCapturer(delegate: videoSource)
        }else if TARGET_OS_SIMULATOR != 0 {
            print("now runnnig on simulator...")
            self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        }
        else {
            self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        }
        let videoTrack = RTCFactory.shared.peerConnectionFactory().videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    private func sendOffer() {
        guard let constraints = self.mediaConstraints?.getOfferConstraints() else {
            return
        }
        self.peerConnection.offer(for: constraints, completionHandler: { [weak self](sdp, error) in
            if error == nil, let sdp = sdp, let videoCode = self?.mediaConstraints?.videoCode {
                let sdpPreferringCodec = descriptionForDescription(description: sdp,
                                                                   preferredForDescription: videoCode)
                self?.peerConnection.setLocalDescription(sdp, completionHandler: { [weak self](error) in
                    if let error = error {
                        debugPrint("Publish Role setLocalDescription error: \(String(describing: error.localizedDescription))")
                    } else if let publishMediaConstraints = self?.mediaConstraints as? JanusPublishMediaConstraints {
                        
                        let jsep = ["type": "offer", "sdp": sdpPreferringCodec.sdp]
                        let msg = ["request": "configure",
                                   "audio": NSNumber(value: true),
                                   "video": NSNumber(value: true),
                                   "bitrate": NSNumber(value: publishMediaConstraints.videoBitrate)] as [String : Any]
                        self?.janus.send(message: msg, jsep: jsep, handleId: self!.handleId, callback: { [weak self](msg, jsep) in
                            if let status = msg["configured"] as? String, status == "ok" {
                                if let jsep = jsep {
                                    self?.handleRemote(jsep: jsep)
                                }
                            }
                        })
                    }
                })
                self?.configBitrate()
            }
        })
    }
    
    private func configBitrate() {
        if let publishMediaConstraints = self.mediaConstraints as? JanusPublishMediaConstraints {
            if publishMediaConstraints.videoBitrate > 0 {
                debugPrint("configBitrate senders: \(self.peerConnection.senders.count)")
                for sender in self.peerConnection.senders {
                    if let track = sender.track {
                        if track.kind == kARDVideoTrackKind {
                            let paramsToModify = sender.parameters
                            for encoding in paramsToModify.encodings {
                                encoding.maxBitrateBps = NSNumber(value: publishMediaConstraints.videoBitrate)
                            }
                            sender.parameters = paramsToModify
                        }
                    }
                }
            }
        }
    }
}

extension JanusRolePublish: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        let isLandScape = size.width < size.height
        var renderView: RTCEAGLVideoView?
        var parentView: UIView?
        if videoView.isEqual(localRenderView){
            print("local video size changed")
            renderView = localRenderView
            parentView = localRenderView?.superview
        }
        
        guard let _renderView = renderView, let _parentView = parentView else { return }
        
        if(isLandScape){
            let ratio = size.width / size.height
            _renderView.frame = CGRect(x: 0, y: 0, width: _parentView.frame.height * ratio, height: _parentView.frame.height)
            _renderView.center.x = _parentView.frame.width/2
        }else{
            let ratio = size.height / size.width
            _renderView.frame = CGRect(x: 0, y: 0, width: _parentView.frame.width, height: _parentView.frame.width * ratio)
            _renderView.center.y = _parentView.frame.height/2
        }
    }
}
