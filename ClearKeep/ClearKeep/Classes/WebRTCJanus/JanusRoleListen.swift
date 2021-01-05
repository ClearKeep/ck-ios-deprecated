//
//  JanusRoleListen.swift
//  JanusWebRTC
//
//  Created by Nguyen Luan on 12/19/20.
//  Copyright © 2020 Vmodev. All rights reserved.
//

import UIKit
import WebRTC

protocol JanusRoleListenDelegate: JanusRoleDelegate {
    func janusRoleListen(role: JanusRoleListen, firstRenderWithSize size: CGSize)
    func janusRoleListen(role: JanusRoleListen, renderSizeChangeWithSize size: CGSize)
}

class JanusRoleListen: JanusRole {
    var _renderView: RTCEAGLVideoView? = nil
    var videoTrack: RTCVideoTrack?
    private var remoteStream: RTCMediaStream?
    var renderSize: CGSize = .zero
    
    override init(withJanus janus: Janus, delegate: JanusRoleDelegate? = nil) {
        super.init(withJanus: janus, delegate: delegate)
        self.pType = .lister
        self.mediaConstraints = JanusMediaConstraints()
        self.mediaConstraints?.audioEnable = true
        self.mediaConstraints?.videoEnable = true
    }
    
    override class func role(withDict dict: [String: Any],
                              janus: Janus,
                              delegate: JanusRoleDelegate?) -> JanusRoleListen {
        let publish = JanusRoleListen(withJanus: janus, delegate: delegate)
        publish.pType = .lister
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
    
    override func joinRoom(withRoomId roomId: Int, username: String?, callback: @escaping RoleJoinRoomCallback) {
        if !self.attached, self.status == .detached, roomId > 0 {
            self.attach { [weak self](error) in
                if let error = error {
                    callback(error)
                } else {
                    if let self = self {
                        self.joinRoom(withRoomId: roomId, username: username) { (error) in
                            callback(error)
                        }
                    } else {
                        callback(JanusResultError.codeErr(code: -1, desc: "Listener attach error"))
                    }
                }
            }
            return
        }
        super.joinRoom(withRoomId: roomId, username: username, callback: callback)
    }
    
    override func leaveRoom(callback: @escaping RoleLeaveRoomCallback) {
        self.detach {
            callback()
        }
    }
    
    override func handleRemote(jsep: [String : Any]) {
        if let sdp = jsep["sdp"] as? String {
            var sdpType = RTCSdpType.answer
            if let type = jsep["type"] as? String, type == "answer" {
                sdpType = .answer
            } else if let type = jsep["type"] as? String, type == "offer" {
                sdpType = .offer
            } else {
                debugPrint("No handle remote jsep")
            }
            
            let sessionDest = RTCSessionDescription(type: sdpType, sdp: sdp)
            self.peerConnection.setRemoteDescription(sessionDest, completionHandler: { [weak self](error) in
                if let error = error {
                    debugPrint("Listen Role setRemoteDescription error: \(error.localizedDescription)")
                } else {
                    self?.peerConnection.answer(for: (self?.mediaConstraints?.getAnswerConstraints())!,
                                                 completionHandler: { (sdp, error) in
                        if let error = error {
                            debugPrint("peerConnection answerForConstraints error: \(error.localizedDescription)")
                        } else if let sdpDict = sdp {
                            self?.peerConnection.setLocalDescription(sdpDict, completionHandler: { (error) in
                                if let error = error {
                                    debugPrint("peerConnection?.setLocalDescription error: \(error.localizedDescription)")
                                }
                            })
                            let jsep = ["type": "answer", "sdp": sdpDict.sdp]
                            self?.prepareLocalJsep(jsep: jsep)
                        }
                    })
                }
            })
        } else {
            debugPrint("sdp jsep is nil")
        }
    }
    
    func prepareLocalJsep(jsep: [String: Any]) {
        let msg = ["request": "start", "room": NSNumber(value: self.roomId!)] as [String : Any]
        self.janus.send(message: msg, jsep: jsep, handleId: handleId) { (msg, jsep) in
            if let action = msg["started"] as? String, action == "ok" {
                debugPrint("prepareLocalJsep ok")
            }
        }
    }
    
    // MARK: - UIView Render
    func setupRemoteViewFrame(frame: CGRect) {
//        remoteRenderView?.frame = frame
        renderView.frame = frame
    }

    func removeRemoteView() {
        _renderView?.removeFromSuperview()
        _renderView = nil
    }
    
    var renderView: RTCEAGLVideoView {
        if let renderView = _renderView {
            return renderView
        }
        _renderView = RTCEAGLVideoView()
        _renderView?.isUserInteractionEnabled = false
        _renderView?.delegate = self
        if let videoTrack = self.videoTrack {
            videoTrack.add(_renderView!)
        }
        return _renderView!
    }
}

extension JanusRoleListen: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        if renderSize == .zero {
            renderSize = size
            if let listenDelegate = self.delegate as? JanusRoleListenDelegate {
                listenDelegate.janusRoleListen(role: self, firstRenderWithSize: size)
            }
        } else {
            if let listenDelegate = self.delegate as? JanusRoleListenDelegate {
                listenDelegate.janusRoleListen(role: self, renderSizeChangeWithSize: size)
            }
        }
    }
}

extension JanusRoleListen {
    override func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        asyncInMainThread {
            if stream.videoTracks.count > 0 {
                let videoTrack = stream.videoTracks[0]
                videoTrack.add(self.renderView)
                self.videoTrack = videoTrack
            }
        }
    }
    
    override func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("")
    }
}

//extension JanusRoleListen: RTCEAGLVideoViewDelegate {
//    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
//        if renderSize == .zero {
//            renderSize = size
//            if let listenDelegate = self.delegate as? JanusRoleListenDelegate {
//                listenDelegate.janusRoleListen(role: self, firstRenderWithSize: size)
//            }
//        } else {
//            if let listenDelegate = self.delegate as? JanusRoleListenDelegate {
//                listenDelegate.janusRoleListen(role: self, renderSizeChangeWithSize: size)
//            }
//        }
//    }
//
//    override func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
//        asyncInMainThread {
//            if stream.videoTracks.count > 0 {
//                let videoTrack = stream.videoTracks[0]
//                videoTrack.add(self.renderView)
//                self.videoTrack = videoTrack
//            }
//        }
//    }
//
//    override func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
//        self.videoTrack = nil
//        self.renderSize = .zero
//    }
//}
