//
//  CallBox.swift
//  ClearKeep
//
//  Created by VietAnh on 1/7/21.
//

import Foundation
import AVFoundation

enum CallStatus {
    case calling
    case ringing
    case answered
    case busy
    case ended
}

final class CallBox: NSObject {

    // MARK: Metadata Properties
    let uuid: UUID
    var username: String = ""
    let isOutgoing: Bool
    var handle: String?
    var status = CallStatus.calling

    // MARK: Call State Properties

    var connectingDate: Date? {
        didSet {
            stateDidChange?()
            hasStartedConnectingDidChange?()
        }
    }
    var connectDate: Date? {
        didSet {
            stateDidChange?()
            hasConnectedDidChange?()
        }
    }
    var endDate: Date? {
        didSet {
            status = .ended
            stateDidChange?()
            hasEndedDidChange?()
        }
    }
    var isOnHold = false {
        didSet {
//            publisher?.publishAudio = !isOnHold
            stateDidChange?()
        }
    }
    
    var isMuted = false {
        didSet {
//            publisher?.publishAudio = !isMuted
        }
    }

    // MARK: State change callback blocks

    var stateDidChange: (() -> Void)?
    var hasStartedConnectingDidChange: (() -> Void)?
    var hasConnectedDidChange: (() -> Void)?
    var hasEndedDidChange: (() -> Void)?
    var audioChange: (() -> Void)?

    // MARK: Derived Properties

    var hasStartedConnecting: Bool {
        get {
            return connectingDate != nil
        }
        set {
            connectingDate = newValue ? Date() : nil
        }
    }
    var hasConnected: Bool {
        get {
            return connectDate != nil
        }
        set {
            connectDate = newValue ? Date() : nil
        }
    }
    var hasEnded: Bool {
        get {
            return endDate != nil
        }
        set {
            endDate = newValue ? Date() : nil
        }
    }
    var duration: TimeInterval {
        guard let connectDate = connectDate else {
            return 0
        }

        return Date().timeIntervalSince(connectDate)
    }

    // MARK: Initialization

    init(uuid: UUID, isOutgoing: Bool = false) {
        self.uuid = uuid
        self.isOutgoing = isOutgoing
    }

    // MARK: Actions
//    var session: OTSession?
//    var publisher: OTPublisher?
//    var subscriber: OTSubscriber?
    var videoRoom: JanusVideoRoom?
    
    var canStartCall: ((Bool) -> Void)?
    func startCall(withAudioSession audioSession: AVAudioSession?, completion: ((_ success: Bool) -> Void)?) {
//        OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance(with: audioSession))
        if videoRoom == nil {
            videoRoom = JanusVideoRoom(delegate: self)
        }
        canStartCall = completion

        hasStartedConnecting = true
        videoRoom?.publisher?.janus.connect(completion: { (error) in
            if let error = error {
                print(error.localizedDescription)
                completion?(false)
            } else {
                completion?(true)
            }
        })
    }
    
    var canAnswerCall: ((Bool) -> Void)?
    func answerCall(withAudioSession audioSession: AVAudioSession, completion: ((_ success: Bool) -> Void)?) {
//        OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance(with: audioSession))
        if videoRoom == nil {
            videoRoom = JanusVideoRoom(delegate: self)
        }
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            appDelegate.viewRouter.current = .callVideo
//        }
        canAnswerCall = completion
        
        hasStartedConnecting = true
        videoRoom?.publisher?.janus.connect(completion: { (error) in
            if let error = error {
                print(error.localizedDescription)
                completion?(false)
            } else {
                completion?(true)
            }
        })
    }
    
    func startJoinRoom() {
        videoRoom?.joinRoom(withRoomId: 1234, username: "", completeCallback: { [weak self](isSuccess, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self?.status = .ringing
                self?.stateDidChange?()
            }
        })
    }
    
    func endCall() {
        /*
         Simulate the end taking effect immediately, since
         the example app is not backed by a real network service
         */
        
        if let videoRoom = self.videoRoom {
            videoRoom.leaveRoom(callback: nil)
        }
        videoRoom = nil
        hasEnded = true
    }
}

extension CallBox: JanusVideoRoomDelegate {
    func janusVideoRoom(janusRoom: JanusVideoRoom, remoteLeaveWithID clientId: Int) {
        
    }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, didJoinRoomWithId clientId: Int) {
        status = .ringing
        self.stateDidChange?()
    }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, remoteUnPublishedWithUid clientId: Int) {
        CallManager.shared.end(call: self)
    }
    
    func janusVideoRoom(janusRoom: JanusVideoRoom, firstFrameDecodeWithSize size: CGSize, uId: Int) {
        status = .answered
        self.stateDidChange?()
    }
}

//extension SpeakerboxCall: OTSessionDelegate {
//    func sessionDidConnect(_ session: OTSession) {
//        print(#function)
//
//        hasConnected = true
//        canStartCall?(true)
//        canAnswerCall?(true)
//    }
//
//    func sessionDidDisconnect(_ session: OTSession) {
//        print(#function)
//    }
//
//    func sessionDidBeginReconnecting(_ session: OTSession) {
//        print(#function)
//    }
//
//    func sessionDidReconnect(_ session: OTSession) {
//        print(#function)
//    }
//
//    func session(_ session: OTSession, didFailWithError error: OTError) {
//        print(#function, error)
//
//        hasConnected = false
//        canStartCall?(false)
//        canAnswerCall?(false)
//    }
//
//    func session(_ session: OTSession, streamCreated stream: OTStream) {
//        print(#function)
//        subscriber = OTSubscriber.init(stream: stream, delegate: self)
//        subscriber?.subscribeToVideo = false
//        if let subscriber = subscriber {
//            var error: OTError?
//            session.subscribe(subscriber, error: &error)
//            if error != nil {
//                print(error!)
//            }
//        }
//    }
//
//
//    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
//        print(#function)
//    }
//}
//
//extension SpeakerboxCall: OTPublisherDelegate {
//    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
//        print(#function)
//    }
//}
//
//extension SpeakerboxCall: OTSubscriberDelegate {
//    func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
//        print(#function)
//    }
//
//    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
//        print(#function)
//    }
//}
