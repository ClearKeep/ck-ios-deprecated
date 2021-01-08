//
//  CallManager.swift
//  ClearKeep
//
//  Created by VietAnh on 1/4/21.
//

import UIKit
import CallKit
import AVFoundation
import PushKit
import SwiftyJSON

final class CallManager: NSObject {
    
    enum Call: String {
        case start = "startCall"
        case end = "endCall"
        case hold = "holdCall"
    }
    var answerCall: CallBox?
    var outgoingCall: CallBox?
    let callController = CXCallController()
    static let CallsChangedNotification = Notification.Name("CallManagerCallsChangedNotification")
    private let provider: CXProvider
    private(set) var calls = [CallBox]()
    /// The app's provider configuration, representing its CallKit capabilities
    static var providerConfiguration: CXProviderConfiguration {
        let localizedName = NSLocalizedString("ClearKeep", comment: "Name of application")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
//        providerConfiguration.iconTemplateImageData = #imageLiteral(resourceName: "IconMask").pngData()
        providerConfiguration.ringtoneSound = "Ringtone.caf"
        return providerConfiguration
    }
    
    static let shared = CallManager()
    
    override init() {
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }

    // MARK: Actions
    func startCall(clientId: String, video: Bool = true) {
        let handle = CXHandle(type: .generic, value: clientId)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)

        startCallAction.isVideo = video

        let transaction = CXTransaction()
        transaction.addAction(startCallAction)

        requestTransaction(transaction, action: Call.start.rawValue)
    }

    func end(call: CallBox) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)

        requestTransaction(transaction, action: Call.end.rawValue)
    }

    func setHeld(call: CallBox, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)

        requestTransaction(transaction, action: Call.hold.rawValue)
    }

    private func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction \(action) successfully")
            }
        }
    }

    // MARK: Call Management
    private func callWithUUID(uuid: UUID) -> CallBox? {
        guard let index = calls.firstIndex(where: { $0.uuid == uuid }) else {
            return nil
        }
        return calls[index]
    }

    private func addCall(_ call: CallBox) {
        calls.append(call)

        call.stateDidChange = { [weak self] in
            self?.postCallsChangedNotification()
        }

        postCallsChangedNotification(userInfo: ["action": Call.start.rawValue])
    }

    private func removeCall(_ call: CallBox) {
        calls = calls.filter {$0 === call}
        postCallsChangedNotification(userInfo: ["action": Call.end.rawValue])
    }

    private func removeAllCalls() {
        calls.removeAll()
        postCallsChangedNotification(userInfo: ["action": Call.end.rawValue])
    }

    private func postCallsChangedNotification(userInfo: [String: Any]? = nil) {
        NotificationCenter.default.post(name: type(of: self).CallsChangedNotification, object: self, userInfo: userInfo)
    }
    
    func handleIncomingPushEvent(payload: PKPushPayload, completion: ((NSError?) -> Void)? = nil) {
        let jsonData = JSON(payload.dictionaryPayload)
        if let username = jsonData["aps"]["from_client"]["username"].string {
            reportIncomingCall(uuid: UUID(), callerName: username, completion: completion)
        }
    }
}

extension CallManager {
    // MARK: Incoming Calls
    /// Use CXProvider to report the incoming call to the system
    func reportIncomingCall(uuid: UUID, callerName: String, hasVideo: Bool = true, completion: ((NSError?) -> Void)? = nil) {
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: callerName)
        update.hasVideo = hasVideo

        // pre-heat the AVAudioSession
        //OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
        
        // Report the incoming call to the system
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            /*
                Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
                since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
             */
            if error == nil {
                let call = CallBox(uuid: uuid)
                call.username = callerName
                call.handle = callerName
                self.addCall(call)
            }
            
            completion?(error as NSError?)
        }
    }

    func sendFakeAudioInterruptionNotificationToStartAudioResources() {
        var userInfo = Dictionary<AnyHashable, Any>()
        let interrupttioEndedRaw = AVAudioSession.InterruptionType.ended.rawValue
        userInfo[AVAudioSessionInterruptionTypeKey] = interrupttioEndedRaw
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: self, userInfo: userInfo)
    }
    
    func configureAudioSession() {
        // See https://forums.developer.apple.com/thread/64544
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default)
            try session.setActive(true)
            try session.setMode(AVAudioSession.Mode.voiceChat)
            try session.setPreferredSampleRate(44100.0)
            try session.setPreferredIOBufferDuration(0.005)
        } catch {
            print(error)
        }
    }
}

extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
        /*
            End any ongoing calls if the provider resets, and remove them from the app's list of calls,
            since they are no longer valid.
         */
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Create & configure an instance of SpeakerboxCall, the app's model class representing the new outgoing call.
        let call = CallBox(uuid: action.callUUID, isOutgoing: true)
        call.handle = action.handle.value

        /*
            Configure the audio session, but do not start call audio here, since it must be done once
            the audio session has been activated by the system after having its priority elevated.
         */
        // https://forums.developer.apple.com/thread/64544
        // we can't configure the audio session here for the case of launching it from locked screen
        // instead, we have to pre-heat the AVAudioSession by configuring as early as possible, didActivate do not get called otherwise
        // please look for  * pre-heat the AVAudioSession *
        configureAudioSession()
        
        /*
            Set callback blocks for significant events in the call's lifecycle, so that the CXProvider may be updated
            to reflect the updated state.
         */
        call.hasStartedConnectingDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: call.connectingDate)
        }
        call.hasConnectedDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, connectedAt: call.connectDate)
        }

        self.outgoingCall = call
        
        self.addCall(call)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.viewRouter.current = .callVideo
        }
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = self.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        /*
            Configure the audio session, but do not start call audio here, since it must be done once
            the audio session has been activated by the system after having its priority elevated.
         */
        
        // https://forums.developer.apple.com/thread/64544
        // we can't configure the audio session here for the case of launching it from locked screen
        // instead, we have to pre-heat the AVAudioSession by configuring as early as possible, didActivate do not get called otherwise
        // please look for  * pre-heat the AVAudioSession *
        configureAudioSession()
        
        self.answerCall = call
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = self.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        // Trigger the call to be ended via the underlying network service.
        call.endCall()

        // Signal to the system that the action has been successfully performed.
        action.fulfill()

        // Remove the ended call from the app's list of calls.
        self.removeCall(call)
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = self.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        // Update the SpeakerboxCall's underlying hold state.
        call.isOnHold = action.isOnHold

        // Stop or start audio in response to holding or unholding the call.
        call.isMuted = call.isOnHold

        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = self.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.isMuted = action.isMuted
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("Timed out \(#function)")

        // React to the action timeout if necessary, such as showing an error UI.
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Received \(#function)")
        
        // If we are returning from a hold state
        if answerCall?.hasConnected ?? false {
            //configureAudioSession()
            // See more details on how this works in the OTDefaultAudioDevice.m method handleInterruptionEvent
            sendFakeAudioInterruptionNotificationToStartAudioResources();
            return
        }
        if outgoingCall?.hasConnected ?? false {
            //configureAudioSession()
            // See more details on how this works in the OTDefaultAudioDevice.m method handleInterruptionEvent
            sendFakeAudioInterruptionNotificationToStartAudioResources()
            return
        }
        
        // Start call audio media, now that the audio session has been activated after having its priority boosted.
        outgoingCall?.startCall(withAudioSession: audioSession) { [weak self] success in
            if success {
                self?.outgoingCall?.startJoinRoom()
            } else {
                if let outgoingCall = self?.outgoingCall {
                    self?.end(call: outgoingCall)
                }
            }
        }
        
        answerCall?.answerCall(withAudioSession: audioSession) { success in
            if success {
                DispatchQueue.main.async {
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.viewRouter.current = .callVideo
                    }
                }
                self.answerCall?.startJoinRoom()
            }
        }
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Received \(#function)")

        /*
             Restart any non-call related audio now that the app's audio session has been
             de-activated after having its priority restored to normal.
         */
        if outgoingCall?.isOnHold ?? false || answerCall?.isOnHold ?? false {
            print("Call is on hold. Do not terminate any call")
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.outgoingCall?.endCall()
            self.outgoingCall = nil
            self.answerCall?.endCall()
            self.answerCall = nil
            self.removeAllCalls()
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.viewRouter.current = .login
            }
        }
    }
}











































//MARK: - Stringee code call manager
//import Foundation
//import CallKit
//import CoreTelephony
//import PushKit
//import SwiftyJSON
//import AVFoundation
//
//class CallManager: NSObject {
//
//    // MARK: - Init
//
//    static let shared = CallManager()
//
//    var call: CallModel?
//    var callViewModel: CallViewModel?
//    var videoRoom: Int? = 1234
//    lazy var trackedCalls = [String: CallModel]()
//
//    private var _provider: AnyObject?
//    private var provider: CXProvider {
//        if _provider == nil {
//            let configuration = CXProviderConfiguration(localizedName: "Stringee")
//            configuration.supportsVideo = true
//            configuration.maximumCallGroups = 1
//            configuration.maximumCallsPerCallGroup = 1
//            configuration.supportedHandleTypes = [.generic, .phoneNumber]
//            _provider = CXProvider(configuration: configuration)
//        }
//
//        return _provider as! CXProvider
//    }
//
//    private var _callController: AnyObject?
//    private var callController: CXCallController {
//        if _callController == nil {
//            _callController = CXCallController()
//        }
//
//        return _callController as! CXCallController
//    }
//
//    private var _callObserver: AnyObject?
//    private var callObserver: CXCallObserver {
//        if _callObserver == nil {
//            _callObserver = CXCallObserver()
//        }
//
//        return _callObserver as! CXCallObserver
//    }
//
//    var watingForUpdateCallKit: (() -> Void)?
//    var showingCallKitUUID: UUID?
//
//    override init() {
//        super.init()
//        provider.setDelegate(self, queue: DispatchQueue.main)
//    }
//
//    // MARK: - Actions
//
//    func hasSystemCall() -> Bool {
//        return callObserver.calls.count > 0
//    }
//
//    func reportIncomingCall(clientId: String, callerName: String, isVideo: Bool, completion: @escaping (Bool, UUID) -> ()) {
//        let callUpdate = CXCallUpdate()
//        callUpdate.hasVideo = isVideo
//        callUpdate.remoteHandle = CXHandle(type: .generic, value: clientId)
//        callUpdate.localizedCallerName = callerName
//        let uuid = UUID()
//
//        showingCallKitUUID = uuid
//        provider.reportNewIncomingCall(with: uuid, update: callUpdate) {[weak self] (error) in
//            guard let self = self else { completion(false, uuid); return }
//
//            self.watingForUpdateCallKit?()
//            self.watingForUpdateCallKit = nil
//            self.showingCallKitUUID = nil
//
//            if error == nil {
//                self.configureAudioSession()
//                completion(true, uuid)
//            } else {
//                completion(false, uuid)
//            }
//        }
//
//    }
//
//    func reportUpdatedCall(phone: String, callerName: String, isVideo: Bool, uuid: UUID) {
//        let callUpdate = CXCallUpdate()
//        callUpdate.hasVideo = isVideo
//        callUpdate.remoteHandle = CXHandle(type: .generic, value: phone)
//        callUpdate.localizedCallerName = callerName
//        provider.reportCall(with: uuid, updated: callUpdate)
//    }
//
//    func startCall(phone: String, calleeName: String, videoCallRoom: JanusVideoRoom, isVideo: Bool = true) {
//        if (call != nil) {
//            return
//        }
//
//        let handle = CXHandle(type: .generic, value: phone)
//        call = CallModel(isIncoming: false)
//        call?.uuid = UUID()
//        call?.videoCallRoom = videoCallRoom
//
//        let startCallAction = CXStartCallAction(call: (call?.uuid)!, handle: handle)
//        startCallAction.isVideo = isVideo
//        startCallAction.contactIdentifier = calleeName
//
//        let transaction = CXTransaction()
//        transaction.addAction(startCallAction)
//        requestTransaction(transaction: transaction)
//    }
//
//    func endCall() {
//        if let uuid = self.call?.uuid {
//            provider.updateConfiguration(includesCallsInRecents: true)
//            let endCallAction = CXEndCallAction(call: uuid)
//            let transaction = CXTransaction()
//            transaction.addAction(endCallAction)
//            requestTransaction(transaction: transaction)
//        }
//    }
//
//    func holdCall(hold: Bool) {
//        if let uuid = self.call?.uuid {
//            let holdCallAction = CXSetHeldCallAction(call: uuid, onHold: hold)
//            let transaction = CXTransaction()
//            transaction.addAction(holdCallAction)
//            requestTransaction(transaction: transaction)
//        }
//    }
//
//    func requestTransaction(transaction: CXTransaction) {
//        callController.request(transaction) { [unowned self] (error) in
//            if error != nil {
//                print("requestTransaction: \(String(describing: error?.localizedDescription))")
//                // End Callkit va xoa current call
//                self.endCall()
//                self.call = nil
//
//                // Co man hinh calling => dismiss
//                if let callViewModel = self.callViewModel {
//                    callViewModel.endCallAndDismiss()
//                }
//            }
//        }
//    }
//
//    func configureAudioSession() {
//        print("CONFIGURE AUDIO SESSION")
//        let audioSession = AVAudioSession.sharedInstance()
//
//        do {
//            try audioSession.setCategory(.playAndRecord, mode: .videoChat)
//            try audioSession.setPreferredSampleRate(44100.0)
//            try audioSession.setPreferredIOBufferDuration(0.005)
//        } catch  {
//            print("Cấu hình audio session cho callkit thất bại")
//        }
//    }
//}
//
//// MARK: - Handle iOS 13
//
//extension CallManager {
//    //
//    func handleIncomingPushEvent(payload: PKPushPayload) {
//        let jsonData = JSON(payload.dictionaryPayload)
//        let payLoadData = jsonData["data"]["map"]["data"]["map"]
//        guard let callStatus = payLoadData["callStatus"].string,
//              let callId = payLoadData["callId"].string,
//              let pushType = jsonData["data"]["map"]["type"].string,
//              !callStatus.isEmpty, !callId.isEmpty, callStatus == "started", pushType == "CALL_EVENT" else {
//
//            // Report 1 cuộc gọi fake và reject luôn => cho các trường hợp không thoả mãn
//            CallManager.shared.reportAFakeCall()
//            return
//        }
//
//        if call != nil {
//            CallManager.shared.reportAFakeCall()
//            return
//        }
//
//        // Đã show rồi thì thôi
//        let callSerial = jsonData["data"]["map"]["data"]["map"]["serial"].intValue
//        if let _ = getTrackedCall(callId: callId, serial: callSerial) {
//            CallManager.shared.reportAFakeCall()
//            return
//        }
//
//        // Show 1 cuộc gọi chưa có đủ thông tin hiển thị => Update khi nhận được incoming call
//        print("INCOMING PUSH -- SERIAL \(callSerial)")
//        call = CallModel(isIncoming: true)
//        call?.callId = callId
//        call?.serial = callSerial
//        call?.videoCallRoom = JanusVideoRoom()
//        trackCall(call!)
//
//
//        let alias = payLoadData["from"]["map"]["alias"].string
//        let number = payLoadData["from"]["map"]["number"].string
//        let clientId: String = number ?? ""
//
//        let callerName: String = alias ?? number ?? "Connecting Call..."
//
//        reportIncomingCall(clientId: clientId, callerName: callerName, isVideo: false) { [unowned self] (status, uuid) in
//            DispatchQueue.main.async {
//                if (status) {
//                    // thành công thì gán lại uuid
//                    self.call?.uuid = uuid
//                } else {
//                    // thất bại thì xoá call
//                    self.call?.clean()
//                    self.call = nil
//                }
//            }
//        }
//
//        // có push nhưng không có incomingCall
//        startCheckingReceivingTimeoutOfStringeeCall()
//    }
//
//    // app is running
//    //    func handleIncomingCallEvent(stringeeCall: StringeeCall) {
//    //        print("INCOMING CALLID \(String(describing: stringeeCall.callId)) -- SERIAL \(stringeeCall.serial)")
//    //
//    //        func showCallKitFor(stringeeCall: StringeeCall) {
//    //            print("INCOMING CALL - SHOW CALLKIT")
//    //            call = CallModel(isIncoming: true)
//    //            call?.callId = stringeeCall.callId
//    //            call?.stringeeCall = stringeeCall
//    //            call?.serial = Int(stringeeCall.serial)
//    //            trackCall(call!)
//    //
//    //            reportIncomingCall(phone: stringeeCall.from, callerName: stringeeCall.fromAlias, isVideo: stringeeCall.isVideoCall) { [unowned self] (status, uuid) in
//    //                if (status) {
//    //                    self.call?.uuid = uuid
//    //                    DispatchQueue.main.async {
//    //                        InstanceManager.shared.callingVC?.btAnswer.isEnabled = true
//    //                        InstanceManager.shared.callingVC?.btReject.isEnabled = true
//    //                    }
//    //                } else {
//    //                    self.call?.clean()
//    //                    self.call = nil
//    //                }
//    //            }
//    //        }
//    //
//    //        func showCallingVC(stringeeCall: StringeeCall) {
//    //            if InstanceManager.shared.callingVC != nil {
//    //                stringeeCall.reject { (status, code, message) in
//    //                    print(message ?? "")
//    //                }
//    //                return
//    //            }
//    //
//    //            DispatchQueue.main.async {
//    //                let callControl = CallControl()
//    //                let callingVC = CallingViewController.init(control: callControl, call: stringeeCall)
//    //                callingVC.modalPresentationStyle = .fullScreen
//    //                UIApplication.shared.keyWindow?.rootViewController?.present(callingVC, animated: true, completion: nil)
//    //            }
//    //        }
//    //
//    //        DispatchQueue.main.async {
//    //            if self.call == nil && InstanceManager.shared.callingVC == nil {
//    //                // Chưa show callkit thì show
//    //                showCallKitFor(stringeeCall: stringeeCall)
//    //                showCallingVC(stringeeCall: stringeeCall)
//    //                stringeeCall.initAnswer()
//    //                self.answerCallWithCondition(shouldChangeUI: false)
//    //                return
//    //            }
//    //
//    //            if let callId = self.call?.callId, callId == stringeeCall.callId {
//    //                if let uuid = self.call?.uuid {
//    //                    // Nếu đã show callkit cho call này rồi => update thông tin
//    //                    self.updateCallkitInfoFor(stringeeCall: stringeeCall, uuid: uuid)
//    //                } else {
//    //                    self.watingForUpdateCallKit = { [weak self] in
//    //                        if let uuid = self?.showingCallKitUUID, let stCall = self?.call?.stringeeCall {
//    //                            self?.updateCallkitInfoFor(stringeeCall: stCall, uuid: uuid)
//    //                        }
//    //                    }
//    //                }
//    //                self.call?.stringeeCall = stringeeCall
//    //                showCallingVC(stringeeCall: stringeeCall)
//    //                stringeeCall.initAnswer()
//    //                self.answerCallWithCondition(shouldChangeUI: false)
//    //            } else {
//    //                // Đang show cho call khác thì reject call mới. Vẫn có thể có push đến sau nên cần track để không show nữa
//    //                let rejectedCall = CallModel(isIncoming: true)
//    //                rejectedCall.callId = stringeeCall.callId
//    //                rejectedCall.serial = Int(stringeeCall.serial)
//    //                self.trackCall(rejectedCall)
//    //
//    //                stringeeCall.reject { (status, code, message) in
//    //                    print("REJECT INCOMING CALL BECAUSE CALLKIT IS SHOWN")
//    //                }
//    //            }
//    //        }
//    //    }
//
//    func reportAFakeCall() {
//        let callUpdate = CXCallUpdate()
//        callUpdate.hasVideo = false
//        //        callUpdate.remoteHandle = CXHandle(type: .generic, value: "0123456789")
//        callUpdate.localizedCallerName = "Expired Call"
//        let uuid = UUID()
//
//        provider.reportNewIncomingCall(with: uuid, update: callUpdate) {[unowned self] (error) in
//            if error != nil {
//                print(error!.localizedDescription)
//            }
//
//            DispatchQueue.main.async {
//                self.provider.updateConfiguration(includesCallsInRecents: false)
//                let endCallAction = CXEndCallAction(call: uuid)
//                let transaction = CXTransaction(action: endCallAction)
//                self.callController.request(transaction) { error in
//                    if error != nil {
//                        print("FAKE CALL === END CALLKIT ERROR \(error!.localizedDescription)")
//                    }
//                }
//            }
//        }
//
//    }
//
//    // Sau 4s từ khi connected hoặc nhận push mà không nhận được incomingCall event - Trường hợp nhận được push, nhưng call bị ngắt ngay nên ko nhận được incomingCall
//    func startCheckingReceivingTimeoutOfStringeeCall() {
//        perform(#selector(CallManager.checkReceivingTimeout), with: nil, afterDelay: 4)
//    }
//
//    func stopCheckingReceivingTimeoutOfStringeeCall() {
//        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(CallManager.checkReceivingTimeout), object: nil)
//    }
//
//    @objc private func checkReceivingTimeout() {
//        guard let call = self.call else {
//            return
//        }
//
//        // Đã show callkit nhưng chưa có videoCallRoom => End callkit
//        if call.uuid != nil && call.videoCallRoom == nil {
//            self.endCall()
//        }
//    }
//}
//
//// MARK: - Call Actions
//
//extension CallManager {
//
//    func answer(shouldChangeUI: Bool = true) {
//        if let callViewModel = self.callViewModel, shouldChangeUI {
//            callViewModel.callStatus = .answered
//        }
//
//        guard let videoCallRoom = call?.videoCallRoom, let videoRoom = self.videoRoom else { return }
//
//        if let answerAction = self.call?.answerAction {
//            answerAction.fulfill()
//            self.call?.answerAction = nil
//            return
//        }
//
//        videoCallRoom.joinRoom(withRoomId: videoRoom, username: "IOS") { [weak self](isSuccess, error) in
//            if !isSuccess {
//                self?.endCall()
//            }
//        }
//    }
//
////    func reject(_ stringeeCall: StringeeCall? = nil) {
////        call?.rejected = true
////
////        var callNeedToReject: StringeeCall? = nil
////        if let seCall = stringeeCall {
////            callNeedToReject = seCall
////        } else if let seCall = call?.stringeeCall {
////            callNeedToReject = seCall
////        } else {
////            return
////        }
////
////        callNeedToReject?.reject { [unowned self] (status, code, message) in
////            print("====== REJECT \(String(describing: message))")
////            if let callingVC = InstanceManager.shared.callingVC {
////                callingVC.endCallAndDismis()
////            }
////
////            if !status {
////                self.endCall()
////            }
////        }
////    }
////
////    func hangup(_ stringeeCall: StringeeCall? = nil) {
////        var callNeedToHangup: StringeeCall? = nil
////        if let seCall = stringeeCall {
////            callNeedToHangup = seCall
////        } else if let seCall = call?.stringeeCall {
////            callNeedToHangup = seCall
////        } else {
////            return
////        }
////
////        //        guard let stringeeCall = call?.stringeeCall else { return }
////
////        callNeedToHangup?.hangup { [unowned self] (status, code, message) in
////            if let callingVC = InstanceManager.shared.callingVC {
////                callingVC.endCallAndDismis()
////            }
////
////            if !status {
////                self.endCall()
////            }
////        }
////    }
//
//    func mute(completion: ((Bool) -> Void)? = nil) {
////        guard let callingVC = InstanceManager.shared.callingVC, let stringeeCall = call?.stringeeCall else {
////            completion?(false)
////            return
////        }
////        stringeeCall.mute(!callingVC.callControl.isMute)
////        callingVC.callControl.isMute = !callingVC.callControl.isMute
////        completion?(true)
//    }
//
//    private func answerCallWithCondition(shouldChangeUI: Bool = true) {
//        guard let callModel = call else { return }
//
//        if callModel.isIncoming && callModel.answered && (callModel.audioIsActived || callModel.answerAction != nil) {
//            answer(shouldChangeUI: shouldChangeUI)
//        }
//    }
//}
//
//// MARK: - Mapping Call
//
//extension CallManager {
//    private func trackCall(_ callNeedToTrack: CallModel) {
//        let key = callNeedToTrack.callId! + "-" + callNeedToTrack.serial.description
//        print("===== KEY TO SAVE CALL <> \(key)")
//        trackedCalls[key] = callNeedToTrack
//    }
//
//    private func getTrackedCall(callId: String, serial: Int) -> CallModel? {
//        let key = callId + "-" + serial.description
//        print("===== KEY TO GET CALL <> \(key)")
//        return trackedCalls[key]
//    }
//}
//
//// MARK: - Callkit Delegate
//
//@available(iOS 10.0, *)
//extension CallManager: CXProviderDelegate {
//
//    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
//        print("CXStartCallAction")
//        configureAudioSession()
//
//        provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)
//        provider.reportOutgoingCall(with: action.callUUID, connectedAt: nil)
//
//        action.fulfill()
//    }
//
//    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
//        print("======== CALLKIT ANSWERED \(action.callUUID)")
//        if call?.uuid?.uuidString != action.callUUID.uuidString {
//            action.fulfill()
//            return
//        }
//
//        call?.answered = true
//        call?.answerAction = action
//        call?.clean()
//        answerCallWithCondition()
//    }
//
//    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
//        print("======== CALLKIT ENDED \(action.callUUID)")
//        if let uuidString = call?.uuid?.uuidString, uuidString != action.callUUID.uuidString {
//            action.fulfill()
//            return
//        }
//
//        call?.clean()
//
//        guard let callModel = call else {
//            action.fulfill()
//            call = nil
//            return
//        }
//
//        call = nil
//
////        if stringeeCall.signalingState != .busy && stringeeCall.signalingState != .ended {
////            if CallModel.isIncoming && !CallModel.answered {
////                reject(stringeeCall)
////            } else {
////                hangup(stringeeCall)
////            }
////        }
//
//        action.fulfill()
//    }
//
//    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
//        print("CXSetHeldCallAction")
//        action.fulfill()
//    }
//
//    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
//        print("CXSetMutedCallAction")
//        mute { (status) in
//            if status {
//                action.fulfill()
//            } else {
//                action.fail()
//            }
//        }
//    }
//
//    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
//        print("didActivate audioSession")
//        call?.audioIsActived = true
//        answerCallWithCondition()
//    }
//
//    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
//        print("didDeactivate audioSession")
//        call?.audioIsActived = false
//    }
//
//    func providerDidReset(_ provider: CXProvider) {
//        print("providerDidReset")
//    }
//
//    func providerDidBegin(_ provider: CXProvider) {
//        print("providerDidBegin")
//    }
//
//    func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
//        print("CXSetGroupCallAction")
//
//    }
//
//    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
//        print("CXPlayDTMFCallAction")
//
//    }
//
//    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
//        print("timedOutPerforming")
//
//    }
//
//    private func providerConfig(includesCallsInRecents: Bool) -> CXProviderConfiguration {
//        let configuration = CXProviderConfiguration(localizedName: "Stringee")
//        configuration.supportsVideo = true
//        configuration.maximumCallsPerCallGroup = 1
//        configuration.maximumCallGroups = 1
//        configuration.supportedHandleTypes = [.generic]
//        if #available(iOS 11.0, *) {
//            configuration.includesCallsInRecents = includesCallsInRecents
//        }
//        return configuration
//    }
//}
//
//fileprivate extension CXProvider {
//    func updateConfiguration(includesCallsInRecents: Bool) {
//        if #available(iOS 11.0, *) {
//            let newConfig = configuration
//            guard newConfig.includesCallsInRecents != includesCallsInRecents else { return }
//            newConfig.includesCallsInRecents = includesCallsInRecents
//            configuration = newConfig
//        }
//    }
//}
