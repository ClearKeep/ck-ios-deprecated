//
//  JanusVideoRoom.swift
//  JanusWebRTC
//
//  Created by VietAnh on 12/21/20.
//  Copyright © 2020 Vmodev. All rights reserved.
//

import UIKit
import AVFoundation
import WebRTC

protocol JanusVideoRoomDelegate: NSObject {
    func janusVideoRoom(janusRoom: JanusVideoRoom, didJoinRoomWithId clientId: Int)
    func janusVideoRoom(janusRoom: JanusVideoRoom, remoteLeaveWithID clientId: Int)
    func janusVideoRoom(janusRoom: JanusVideoRoom, remoteUnPublishedWithUid clientId: Int)
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, firstFrameDecodeWithSize size: CGSize, uId: Int)
}

extension JanusVideoRoomDelegate {
    func janusVideoRoom(janusRoom: JanusVideoRoom, didSetRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) { }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, didSetLocalVideoTrack localVideoTrack: RTCVideoTrack) { }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, newRemoteJoinWithID clientId: Int) { }
    
    func janusVideoRoomDidLeaveRoom(janusRoom: JanusVideoRoom) { }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, renderSizeChangeWithSize size: CGSize, uId: Int) { }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, fatalErrorWithID code: RTCErrorCode) { }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, netBrokenWithID reason: RTCNetBrokenReason) { }
}

class JanusVideoRoom: NSObject {
    var delegate: JanusVideoRoomDelegate? = nil
    private var _localConfig = JanusPublishMediaConstraints()
    var localConfig: JanusPublishMediaConstraints {
        set {
            publisher?.mediaConstraints = newValue
            _localConfig = newValue
        }
        get { return _localConfig }
    }
    var remotes = [Int: JanusRoleListen]()
    var janus: Janus?
    var publisher: JanusRolePublish?
    var canvas = [Int: RTCCanvas]()
    
    private var userId: Int = 0
    private var username: String? = nil
    private var roomId: Int = 0
    var cameraSession: CameraSession?
    var cameraFilter: CameraFilter?
    var useCustomCapturer = false
    
    static var instance: JanusVideoRoom?
    
    static func shared(withServer server: URL, delegate: JanusVideoRoomDelegate? = nil) -> JanusVideoRoom {
        if let _ = self.instance {
//            if instance.delegate != delegate {
//                instance.delegate = delegate
//            }
            // update url server
        } else {
            instance = JanusVideoRoom(withServer: server, delegate: delegate)
        }
        return instance!
    }
    
    init(withServer server: URL, delegate: JanusVideoRoomDelegate? = nil) {
        super.init()
        janus = Janus(withServer: server, delegate: self)
        publisher = JanusRolePublish(withJanus: janus!, delegate: self)
        publisher?.setup(customFrameCapturer: useCustomCapturer)
        
        print("--- use custom capturer ---")
        if self.useCustomCapturer {
            self.cameraSession = CameraSession()
            self.cameraSession?.delegate = self
            self.cameraSession?.setupSession()
            
            self.cameraFilter = CameraFilter()
        }
    }
    
    func updateJanus(withServer server: URL) {
        if janus?.server.absoluteString != server.absoluteString {
            janus?.destroySession()
            janus = Janus(withServer: server, delegate: self)
        }
    }
    
    func joinRoom(withRoomId roomId: Int,
                  username: String,
                  completeCallback callback: CompleteCallback?) {
        self.roomId = roomId
        self.username = username
        
        publisher?.joinRoom(withRoomId: roomId, username: username, callback: { [weak self](error) in
            if let callback = callback {
                callback(error == nil, error)
            } else {
                asyncInMainThread {
                    if let self = self {
                        self.delegate?.janusVideoRoom(janusRoom: self, didJoinRoomWithId: (self.publisher?.id)!)
                    }
                }
            }
        })
    }
    
    func leaveRoom(callback: (() -> ())?) {
        for listenRole in remotes.values {
            listenRole.leaveRoom { [weak self] in
//                let _ = self?.stopPreView(withUid: listenRole.id!)
            }
        }
        remotes.removeAll()
        publisher?.leaveRoom { [weak self] in
            asyncInMainThread {
                if let callback = callback {
                    callback()
                } else {
                    self?.delegate?.janusVideoRoomDidLeaveRoom(janusRoom: self!)
                }
            }
        }
    }
    
//    func startPreView(withCanvas canvas: RTCCanvas) {
//        var canvasChange = canvas
//        if let publisher = self.publisher {
//            if canvas.uid == 0 || canvas.uid == publisher.id {
//                publisher.setupLocalViewFrame(frame: canvas.view.bounds)
//                switch canvas.renderMode {
//                    case .hidden:
//                        canvas.renderView?.contentMode = .scaleAspectFill
//                    case .fit:
//                        canvas.renderView?.contentMode = .scaleAspectFit
//                    case .fill:
//                        canvas.renderView?.contentMode = .scaleToFill
//                }
//                canvas.renderView = publisher.localVideoView()
//                canvas.view.addSubview(publisher.localVideoView())
//            } else {
//                asyncInMainThread {
//                    let role = self.remotes[canvas.uid]
//                    role?.renderView.removeFromSuperview()
//                    role?.setupRemoteViewFrame(frame: canvas.view.bounds)
//                    canvas.view.addObserver(self, forKeyPath: "frame", options: .new, context: &canvasChange)
//                    canvas.view.addSubview((role?.renderView)!)
//                    canvas.renderView = role?.renderView
//                }
//            }
//            self.canvas[canvas.uid] = canvas
//        }
//    }
//
//    func stopPreView(withUid uid: Int) -> RTCCanvas? {
//        if let canvas = self.canvas[uid] {
//            if uid == 0 || uid == publisher?.id {
//                publisher?.stopPreview()
//            } else if let role = remotes[canvas.uid] {
//                canvas.view.removeObserver(self, forKeyPath: "frame")
//                canvas.view.removeFromSuperview()
//                role.removeRemoteView()
//                self.canvas.removeValue(forKey: uid)
//            }
//            return canvas
//        }
//        return nil
//    }
    
    func startListenRemote(remoteRole: JanusRoleListen) {
        self.remotes[remoteRole.id!] = remoteRole
        remoteRole.joinRoom(withRoomId: roomId, username: nil) { [weak self](error) in
            asyncInMainThread {
                if let self = self {
                    self.delegate?.janusVideoRoom(janusRoom: self, newRemoteJoinWithID: remoteRole.id!)
                }
            }
        }
    }
    
    func stopListenRemote(remoteRole: JanusRoleListen) {
        self.remotes.removeValue(forKey: remoteRole.id!)
    }
    
    func updateRenderViewFrame(canvas: RTCCanvas) {
        canvas.renderView?.frame = canvas.view.bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame", let canvas = context as? RTCCanvas {
            updateRenderViewFrame(canvas: canvas)
        }
    }
    
    deinit {
        self.janus?.destroySession()
    }
}

extension JanusVideoRoom: JanusDelegate {
    func janus(_ janus: Janus, createComplete error: Error?) {
        if error != nil {
            asyncInMainThread {
                self.delegate?.janusVideoRoom(janusRoom: self, fatalErrorWithID: .serverErr)
            }
        }
    }
    
    func janus(_ janus: Janus, netBrokenWithId reason: RTCNetBrokenReason) {
        self.leaveRoom(callback: nil)
        asyncInMainThread {
            self.delegate?.janusVideoRoom(janusRoom: self, netBrokenWithID: reason)
        }
    }
    
    func janus(_ janus: Janus, attachPlugin handleId: NSNumber, result error: Error?) { }
    
    func janusDestroy(_ janus: Janus?) { }
}

extension JanusVideoRoom: JanusRoleListenDelegate {
    func janusRolePublish(role: JanusRolePublish, didSetLocalVideoTrack localVideoTrack: RTCVideoTrack) {
        
    }
    
    func janusRolePublish(role: JanusRolePublish, renderSizeChangeWithSize size: CGSize) {
        
    }
    
    func janusRoleListen(role: JanusRoleListen, firstRenderWithSize size: CGSize) {
        self.delegate?.janusVideoRoom(janusRoom: self, firstFrameDecodeWithSize: size, uId: role.id!)
    }
    
    func janusRoleListen(role: JanusRoleListen, renderSizeChangeWithSize size: CGSize) {
        self.delegate?.janusVideoRoom(janusRoom: self, renderSizeChangeWithSize: size, uId: role.id!)
    }
    
    func janusRoleListen(role: JanusRoleListen, didSetRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        
    }
    
    func janusRole(role: JanusRole, joinRoomWithResult error: Error?) {
        if let publisher = self.publisher {
            if role.id == publisher.id {
                asyncInMainThread {
                    self.delegate?.janusVideoRoom(janusRoom: self, didJoinRoomWithId: role.id!)
                }
            }
        }
    }
    
    func janusRole(role: JanusRole, leaveRoomWithResult error: Error?) {
        if let publisher = self.publisher {
            if role.id == publisher.id {
                self.janus?.destroySession()
            }
        }
    }
    
    func janusRole(role: JanusRole?, didJoinRemoteRole remoteRole: JanusRoleListen) {
        for role in self.remotes.values {
            if remoteRole.id == role.id {
                return
            }
        }
        self.startListenRemote(remoteRole: remoteRole)
    }
    
    func janusRole(role: JanusRole, didLeaveRemoteRoleWithUid uid: Int) {
        if let leaveRole = self.remotes[uid] {
            self.remotes.removeValue(forKey: uid)
            leaveRole.detach(withCallback: nil)
            asyncInMainThread {
                self.delegate?.janusVideoRoom(janusRoom: self, remoteLeaveWithID: uid)
            }
        }
    }
    
    func janusRole(role: JanusRole, remoteDetachWithUid uid: Int) {
        if let leaveRole = self.remotes[uid] {
            self.remotes.removeValue(forKey: uid)
            leaveRole.detach(withCallback: nil)
            asyncInMainThread {
                self.delegate?.janusVideoRoom(janusRoom: self, remoteLeaveWithID: uid)
            }
        }
    }
    
    func janusRole(role: JanusRole, remoteUnPublishedWithUid uid: Int) {
        self.delegate?.janusVideoRoom(janusRoom: self, remoteUnPublishedWithUid: uid)
    }
}


// MARK: - CameraSessionDelegate
extension JanusVideoRoom: CameraSessionDelegate {
    func didOutput(_ sampleBuffer: CMSampleBuffer) {
        if self.useCustomCapturer {
            if let cvpixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer){
                if let buffer = self.cameraFilter?.apply(cvpixelBuffer){
                    self.publisher?.captureCurrentFrame(sampleBuffer: buffer)
                    return
                }else{
                    print("no applied image")
                }
            }else{
                print("no pixelbuffer")
            }
            self.publisher?.captureCurrentFrame(sampleBuffer: sampleBuffer)
        }
    }
}
