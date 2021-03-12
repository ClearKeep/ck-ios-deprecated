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
    func janusVideoRoom(janusRoom: JanusVideoRoom, renderSizeChangeWithSize size: CGSize, uId: Int)
}

extension JanusVideoRoomDelegate {
    func janusVideoRoom(janusRoom: JanusVideoRoom, didSetRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) { }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, didSetLocalVideoTrack localVideoTrack: RTCVideoTrack) { }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, newRemoteJoinWithID clientId: Int) { }
    
    func janusVideoRoomDidLeaveRoom(janusRoom: JanusVideoRoom) { }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, fatalErrorWithID code: RTCErrorCode) { }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, netBrokenWithID reason: RTCNetBrokenReason) { }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, didReceiveData data: Data) {}
}

class JanusVideoRoom: NSObject {
    var delegate: JanusVideoRoomDelegate?
    var remotes = [Int: JanusRoleListen]()
    var publisher: JanusRolePublish?
    var canvas = [Int: RTCCanvas]()
    
    private var userId: Int = 0
    private var username: String?
    private var roomId: Int64 = 0
    var useCustomCapturer = false
    
    init(delegate: JanusVideoRoomDelegate? = nil, token: String?) {
        super.init()
//        let server = URL(string: "ws://54.235.68.160:8188/janus") // staging server
//
        let server = URL(string: "ws://54.235.68.160:18188/janus") // dev server

//        let server = URL(string: "ws://10.0.255.82:8188/janus") // Local server
        let janus = Janus(withServer: server!, token: token)
        publisher = JanusRolePublish(withJanus: janus, delegate: self)
        
        self.delegate = delegate
        let localConfig = JanusPublishMediaConstraints()
//        localConfig.resolution = CGSize(width: 4032, height: 3024)
        localConfig.resolution = CGSize(width: 1280, height: 720)
//        localConfig.resolution = CGSize(width: 1024, height: 768)
//        localConfig.resolution = CGSize(width: 960, height: 540)
//        localConfig.resolution = CGSize(width: 640, height: 480)
//        localConfig.resolution = CGSize(width: 480, height: 640)
//        localConfig.resolution = CGSize(width: 192, height: 144)
        localConfig.fps = 30
        localConfig.videoBitrate = 256
        localConfig.audioBirate = 200
        localConfig.frequency = 44100
        publisher?.mediaConstraints = localConfig
        publisher?.setup(customFrameCapturer: useCustomCapturer)
    }
    
    func joinRoom(withRoomId roomId: Int64,
                  username: String,
                  completeCallback callback: CompleteCallback?) {
        self.roomId = roomId
        self.username = username
        AVCaptureDevice.authorizeVideo(completion: { (status) in
            AVCaptureDevice.authorizeAudio(completion: { (status) in
                if status == .alreadyAuthorized || status == .justAuthorized {
                    self.publisher?.joinRoom(withRoomId: roomId, username: username, callback: { [weak self](error) in
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
                } else {
                    print("Permission authorizeAudio denied")
                    if let callbackJoin = callback {
                        callbackJoin(false, nil)
                    } else {
                        self.delegate?.janusVideoRoom(janusRoom: self, fatalErrorWithID: .permission)
                    }
                }
            })
        })
    }
    
    func leaveRoom(callback: (() -> ())?) {
        for listenRole in remotes.values {
            listenRole.leaveRoom {
//                let _ = self?.stopPreView(withUid: listenRole.id!)
                DispatchQueue.main.async {
                    listenRole._renderView?.removeFromSuperview()
                    listenRole.videoTrack = nil
                    listenRole._renderView = nil
                }
            }
        }
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
    
    deinit {
        self.publisher?.janus?.destroySession()
    }
}

extension JanusVideoRoom: JanusRoleListenDelegate {
    
    func janusRoleListen(role: JanusRoleListen, firstRenderWithSize size: CGSize) {
        self.delegate?.janusVideoRoom(janusRoom: self, firstFrameDecodeWithSize: size, uId: role.id!)
    }
    
    func janusRoleListen(role: JanusRoleListen, renderSizeChangeWithSize size: CGSize) {
        self.delegate?.janusVideoRoom(janusRoom: self, renderSizeChangeWithSize: size, uId: role.id!)
    }
    
    func janusRole(role: JanusRole, fatalErrorWithID code: RTCErrorCode) {
        self.delegate?.janusVideoRoom(janusRoom: self, fatalErrorWithID: code)
    }
    
    func janusRole(role: JanusRole, netBrokenWithID reason: RTCNetBrokenReason) {
        self.leaveRoom(callback: nil)
        asyncInMainThread {
            self.delegate?.janusVideoRoom(janusRoom: self, netBrokenWithID: reason)
        }
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
                publisher.janus?.destroySession()
                publisher.janus?.stop()
            }
        }
        self.remotes.removeAll()
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
    
    func janusRole(role: JanusRole, didReceiveData data: Data) {
        self.delegate?.janusVideoRoom(janusRoom: self, didReceiveData: data)
    }
}

extension AVCaptureDevice {
    enum AuthorizationStatus {
        case justDenied
        case alreadyDenied
        case restricted
        case justAuthorized
        case alreadyAuthorized
        case unknown
    }

    class func authorizeVideo(completion: ((AuthorizationStatus) -> Void)?) {
        AVCaptureDevice.authorize(mediaType: AVMediaType.video, completion: completion)
    }

    class func authorizeAudio(completion: ((AuthorizationStatus) -> Void)?) {
        AVCaptureDevice.authorize(mediaType: AVMediaType.audio, completion: completion)
    }

    private class func authorize(mediaType: AVMediaType, completion: ((AuthorizationStatus) -> Void)?) {
        let status = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch status {
        case .authorized:
            completion?(.alreadyAuthorized)
        case .denied:
            completion?(.alreadyDenied)
        case .restricted:
            completion?(.restricted)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        completion?(.justAuthorized)
                    } else {
                        completion?(.justDenied)
                    }
                }
            })
        @unknown default:
            completion?(.unknown)
        }
    }
}
