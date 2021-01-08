//
//  JanusRole.swift
//  JanusWebRTC
//
//  Created by Nguyen Luan on 12/19/20.
//  Copyright © 2020 Vmodev. All rights reserved.
//

import UIKit
import WebRTC

typealias RoleJoinRoomCallback = (Error?) -> ()
typealias RoleLeaveRoomCallback = () -> ()

enum PublishType {
    case lister
    case publish
}

enum JanusRoleStatus: Int {
    case detached
    case detaching
    case attaching
    case attached
    case joining
    case joined
    case leaveing
    case leaved
}

protocol JanusRoleDelegate: JanusPluginDelegate {
    func janusRole(role: JanusRole, joinRoomWithResult error: Error?)
    func janusRole(role: JanusRole, leaveRoomWithResult error: Error?)
    
    func janusRole(role: JanusRole?, didJoinRemoteRole remoteRole: JanusRoleListen)
    func janusRole(role: JanusRole, didLeaveRemoteRoleWithUid uid: Int)
    func janusRole(role: JanusRole, remoteUnPublishedWithUid uid: Int)
    func janusRole(role: JanusRole, remoteDetachWithUid uid: Int)
}

class JanusRole: JanusPlugin {
    var id: Int?
    var roomId: Int?
    var privateId: NSNumber?
    var pType: PublishType = .publish
    var display: String?
    var mediaConstraints: JanusMediaConstraints? = nil
    var status: JanusRoleStatus = .detached
    
    var audioCode: String?
    var videoCode: String?
    
    private var _peerConnection: RTCPeerConnection?
    
    init(withJanus janus: Janus, delegate: JanusRoleDelegate? = nil) {
        super.init(withJanus: janus, delegate: delegate)
        self.opaqueId = "videoroomtest-\(randomString(withLength: 12))"
        self.pluginName = "janus.plugin.videoroom"
    }
    
    class func role(withDict dict: [String: Any], janus: Janus, delegate: JanusRoleDelegate?) -> JanusRole {
        let publish = JanusRole(withJanus: janus, delegate: delegate)
        return publish
    }
    
    override func attach(withCallback callback: AttachResult?) {
        status = .attaching
        super.attach { [weak self](error) in
            if error == nil {
                self?.status = .attached
            } else {
                self?.status = .detached
            }
            if let callback = callback {
                callback(error)
            }
        }
    }
    
    override func detach(withCallback callback: DetachedResult?) {
        if status.rawValue <= JanusRoleStatus.detaching.rawValue {
            return
        }
        status = .detaching
        super.detach { [weak self] in
            self?.status = .detached
            if let callback = callback {
                callback()
            }
        }
        self.destroyRTCPeer()
    }
    
    var peerConnection: RTCPeerConnection {
        if let peerConnection = _peerConnection {
            return peerConnection
        }
        let configuration = RTCConfiguration()
        let optionalDict = ["DtlsSrtpKeyAgreement": "true"]
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: optionalDict)
        _peerConnection = RTCFactory.shared.peerConnectionFactory().peerConnection(with: configuration,
                                                                                 constraints: constraints,
                                                                                 delegate: self)
        return _peerConnection!
    }
    
    func joinRoom(withRoomId roomId: Int, username: String?, callback: @escaping RoleJoinRoomCallback) {
        self.roomId = roomId
        var msg: [String: Any]
        if pType == .publish {
            msg = ["request": "join", "room": NSNumber(value: roomId), "ptype": "publisher"]
            if let username = username {
                msg["display"] = username
            }
        } else {
            msg = ["request": "join", "room": NSNumber(value: roomId), "ptype": "listener"]
            if let id = self.id, let privateId = self.privateId {
                msg["feed"] = NSNumber(value: id)
                msg["private_id"] = privateId
            }
        }
        
        status = .joining
        self.janus.send(message: msg, handleId: handleId) { [weak self](msg, jsep) in
            if let error = msg["error"] as? [String: Any],
                let code = error["error_code"] as? Int,
                let errMsg = msg["error"] as? String {
                callback(JanusResultError.codeErr(code: code, desc: errMsg))
            } else {
                self?.status = .joined
                self?.id = msg["id"] as? Int
                self?.privateId = msg["private_id"] as? NSNumber
                callback(nil)
                if let publishers = msg["publishers"] as? [[String: Any]],
                    let janus = self?.janus,
                    let delegate = self?.delegate as? JanusRoleDelegate {
                    for item in publishers {
                        let listenter = JanusRoleListen.role(withDict: item, janus: janus, delegate: delegate)
                        listenter.privateId = self?.privateId
                        listenter.opaqueId = self?.opaqueId
                        delegate.janusRole(role: self, didJoinRemoteRole: listenter)
                    }
                }
                if let jsep = jsep {
                    self?.handleRemote(jsep: jsep)
                }
            }
        }
    }
    
    func leaveRoom(callback: @escaping RoleLeaveRoomCallback) {
        let msg = ["request": "leave"]
        if status.rawValue > JanusRoleStatus.joining.rawValue {
            status = .leaveing
            self.janus.send(message: msg, handleId: handleId) { [weak self](msg, jsep) in
                self?.status = .leaved
                self?.destroyRTCPeer()
                callback()
            }
        }
    }
    
    func destroyRTCPeer() {
        _peerConnection?.close()
        _peerConnection = nil
    }
    
    deinit {
        self.destroyRTCPeer()
    }
    
    func newRemoteFeed(listener: JanusRoleListen) {
        if let delegate = self.delegate as? JanusRoleDelegate {
            delegate.janusRole(role: self, didJoinRemoteRole: listener)
        }
    }
    
    func handleRemote(jsep: [String: Any]) { }
    
    //MARK: - Janus Delegate
    override func pluginWebrtc(state on: Bool) { }
    
    override func pluginDTLSHangup(withReason reason: String) {
        if self.status == .joined, let roomId = self.roomId {
            self.leaveRoom { [weak self] in
                self?.joinRoom(withRoomId: roomId, username: self?.display, callback: { (error) in
                    if error != nil {
                        debugPrint("joinRoom error: \(error?.localizedDescription ?? "")")
                    }
                })
            }
        }
    }
    
    override func pluginDetected() {
        super.pluginDetected()
        self.status = .detached
    }
}

extension JanusRole: RTCPeerConnectionDelegate {
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        if newState == .complete {
            let publish = ["completed": NSNumber(value: true)]
            send(trickleCandidate: publish)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        var publish: [String: Any]
        if let mid = candidate.sdpMid {
            publish = ["candidate": candidate.sdp,
                       "sdpMid": mid,
                       "sdpMLineIndex": NSNumber(value: candidate.sdpMLineIndex)]
        } else {
            publish = ["completed": NSNumber(value: true)]
        }
        self.send(trickleCandidate: publish)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        
    }
    
    
    
    
}
