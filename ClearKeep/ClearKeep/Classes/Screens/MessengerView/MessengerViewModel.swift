//
//  MessengerViewModel.swift
//  ClearKeep
//
//  Created by VietAnh on 11/10/20.
//

import Foundation
import AVFoundation

class MessengerViewModel: ObservableObject, Identifiable {
    
    // MARK: - Constants
    private let connectionDb = CKDatabaseManager.shared.database?.newConnection()
    
    // MARK: - Variables
    private(set) var groupId: Int64 = Constants.groupIdTemp
    private(set) var receiveId: String = ""
    private(set) var username: String = ""
    private(set) var workspace_domain: String = ""
    private(set) var groupType: String = "peer"
    private(set) var isGroup: Bool = false
    private(set) var isLatestPeerSignalKeyProcessed: Bool = false
    private var isRequesting = false
    
    // MARK: - Published
    @Published var messages: [MessageModel] = []
    
    // MARK: - Init & Deinit
    init() { }
    
    deinit {
        Debug.DLog("Deinit \(self)")
    }
    
    func setup(receiveId: String, groupId: Int64, username: String, workspace_domain: String, groupType: String) {
        self.receiveId = receiveId
        self.username = username
        self.workspace_domain = workspace_domain
        self.groupId = RealmManager.shared.getGroup(by: receiveId, type: groupType)?.groupId ?? Constants.groupIdTemp
        self.groupType = groupType
        isGroup = false
        DispatchQueue.main.async {
            self.messages = self.convertMessage(RealmManager.shared.getAllMessageInGroup(by: self.groupId))
        }
    }
    
    func setup(groupId: Int64, username: String, groupType: String) {
        self.groupId = groupId
        self.groupType = groupType
        self.username = username
        isGroup = true
        DispatchQueue.main.async {
            self.messages = self.convertMessage(RealmManager.shared.getAllMessageInGroup(by: self.groupId))
        }
    }
    
    func setGroupId(_ groupId: Int64) {
        self.groupId = groupId
    }
    
    func setIsLatestPeerSignalKeyProcessed(_ isLatestPeerSignalKeyProcessed: Bool) {
        self.isLatestPeerSignalKeyProcessed = isLatestPeerSignalKeyProcessed
    }
    // MARK: - Data managements
    func reloadData() {
        DispatchQueue.main.async {
            self.messages = self.convertMessage(RealmManager.shared.getAllMessageInGroup(by: self.groupId))
        }
    }
    
    func getGroupModel() -> GroupModel? {
        if let realmGroup = RealmManager.shared.getGroup(by: groupId) {
            var lstClientId = Array<GroupMember>()
            realmGroup.lstClientID.forEach { (member) in
                lstClientId.append(GroupMember(id: member.id, username: member.displayName, workspaceDomain: member.workspaceDomain))
            }
            
            let group = GroupModel(groupID: realmGroup.groupId,
                                   groupName: realmGroup.groupName,
                                   groupToken: realmGroup.groupToken,
                                   groupAvatar: realmGroup.avatarGroup,
                                   groupType: realmGroup.groupType,
                                   createdByClientID: realmGroup.createdByClientID,
                                   createdAt: realmGroup.createdAt,
                                   updatedByClientID: realmGroup.updatedByClientID,
                                   lstClientID: lstClientId,
                                   updatedAt: realmGroup.updatedAt,
                                   lastMessageAt: realmGroup.lastMessageAt,
                                   lastMessage: realmGroup.lastMessage,
                                   idLastMessage: realmGroup.idLastMsg,
                                   isRegistered: realmGroup.isRegistered,
                                   timeSyncMessage: realmGroup.timeSyncMessage)
            return group
        }
        return nil
    }
    
    func getIdLastItem() -> String {
        var id = ""
        if messages.count > 0 {
            id = messages[messages.count - 1].id
        }
        return id
    }
    
    func getMessageInRoom(completion: (() -> ())? = nil) {
        if isGroup {
            getMessageGroup(completion: completion)
        } else {
            getMessagePeerToPeer(completion: completion)
        }
    }
    
    private func getMessagePeerToPeer(completion: (() -> ())? = nil) {
        if groupId != Constants.groupIdTemp {
            Multiserver.instance.currentServer.getMessageInRoom(groupId,
                                            RealmManager.shared.getTimeSyncInGroup(groupId: groupId)) { (result, error) in
                if let result = result {
                    if !result.lstMessage.isEmpty {
                        RealmManager.shared.updateTimeSyncMessageInGroup(groupId: self.groupId, lastMessageAt: result.lstMessage.last?.createdAt ?? 0)
                    }
                    var newMessage = self.messages
                    let dispatchGroup = DispatchGroup()
                    result.lstMessage.forEach { (message) in
                        if !RealmManager.shared.isExistedMessageInGroup(by: message.id, groupId: message.groupID) {
                            dispatchGroup.enter()
                            ChatService.shared.decryptMessageFromPeer(message) { messageModel in
                                newMessage.append(messageModel)
                                dispatchGroup.leave()
                            }
                        }
                    }
                    
                    dispatchGroup.notify(queue: DispatchQueue.main) {
                        self.messages = newMessage
                        completion?()
                    }
                }
            }
        }
    }
    
    private func getMessageGroup(completion: (() -> ())? = nil) {
        if groupId != Constants.groupIdTemp {
            Multiserver.instance.currentServer.getMessageInRoom(groupId , RealmManager.shared.getTimeSyncInGroup(groupId: groupId)) { (result, error) in
                if let result = result {
                    if !result.lstMessage.isEmpty {
                        let listMsgSorted = result.lstMessage.sorted { (msg1, msg2) -> Bool in
                            return msg1.createdAt > msg2.createdAt
                        }
                        RealmManager.shared.updateTimeSyncMessageInGroup(groupId: self.groupId, lastMessageAt: listMsgSorted[0].createdAt)
                    }
                    var newMessage = self.messages
                    let dispatchGroup = DispatchGroup()
                    result.lstMessage.forEach { (message) in
                        if !RealmManager.shared.isExistedMessageInGroup(by: message.id, groupId: message.groupID) {
                            dispatchGroup.enter()
                            ChatService.shared.decryptMessageFromGroup(message) { messageModel in
                                newMessage.append(messageModel)
                                dispatchGroup.leave()
                            }
                        }
                    }
                    
                    dispatchGroup.notify(queue: DispatchQueue.main) {
                        self.messages = newMessage
                        completion?()
                    }
                }
            }
        }
    }
    
    func sendMessage(messageStr: String, completion: (() -> ())? = nil) {
        let messageStr = messageStr.trimmingCharacters(in: .whitespacesAndNewlines)
        if messageStr.isEmpty {
            return
        }
        
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        if isGroup {
            if let group = RealmManager.shared.getGroup(by: groupId) {
                if group.isRegistered {
                    ChatService.shared.sendMessageToGroup(groupId: groupId, messageData: payload) { message in
                        DispatchQueue.main.async {
                            self.messages.append(message)
                        }
                    }
                } else {
                    ChatService.shared.registerWithGroup(group.groupId) { isSuccess in
                        if isSuccess {
                            ChatService.shared.sendMessageToGroup(groupId: group.groupId, messageData: payload) { message in
                                DispatchQueue.main.async {
                                    self.messages.append(message)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            if groupId == Constants.groupIdTemp {
                ChatService.shared.createPeerGroup(receiveId: receiveId, username: username, workspaceDomain: workspace_domain) { [weak self] groupModel in
                    guard let self = self else { return }
                    self.setGroupId(groupModel.groupID)
                    
                    ChatService.shared.sendMessageToPeer(toClientId: self.receiveId, workspaceDomain: self.workspace_domain, groupId: self.groupId, messageData: payload, isForceProcessKey: !self.isLatestPeerSignalKeyProcessed) { [self] message in
                        self.isLatestPeerSignalKeyProcessed = true
                        DispatchQueue.main.async {
                            self.messages.append(message)
                        }
                    }
                }
            } else {
                ChatService.shared.sendMessageToPeer(toClientId: receiveId, workspaceDomain: workspace_domain, groupId: groupId, messageData: payload, isForceProcessKey: !isLatestPeerSignalKeyProcessed) { message in
                    self.isLatestPeerSignalKeyProcessed = true
                    DispatchQueue.main.async {
                        self.messages.append(message)
                    }
                }
            }
        }
    }
    
    func callPeerToPeer(clientId: String, callType type: Constants.CallType = .audio, completion: (() -> ())? = nil){
        if groupId == Constants.groupIdTemp {
            ChatService.shared.createPeerGroup(receiveId: receiveId, username: username, workspaceDomain: workspace_domain) { [weak self] groupModel in
                guard let self = self else { return }
                self.setGroupId(groupModel.groupID)
                
                if self.isRequesting { return }
                self.isRequesting = true
                self.requestVideoCall(isCallGroup: false, clientId: clientId, groupId: groupModel.groupID, callType: type, completion: completion)
            }
        } else {
            if isRequesting { return }
            isRequesting = true
            requestVideoCall(isCallGroup: false, clientId: clientId, groupId: groupId, callType: type, completion: completion)
        }
    }
    
    func callGroup(callType type: Constants.CallType = .audio, completion: (() -> ())? = nil){
        if isRequesting { return }
        isRequesting = true
        requestVideoCall(isCallGroup: true, clientId: receiveId, groupId: groupId, callType: type, completion: completion)
    }
    
    private func requestVideoCall(isCallGroup: Bool ,clientId: String, groupId: Int64, callType type: Constants.CallType = .audio, completion: (() -> ())?) {
        Multiserver.instance.currentServer.videoCall(clientId, groupId, callType: type) { (response, error) in
            self.isRequesting = false
            completion?()
            if let response = response {
                if response.hasStunServer {
                    DispatchQueue.main.async {
                        UserDefaults.standard.setValue(response.turnServer.user, forKey: Constants.keySaveTurnServerUser)
                        UserDefaults.standard.setValue(response.turnServer.pwd, forKey: Constants.keySaveTurnServerPWD)
                        UserDefaults.standard.synchronize()
                        
                        AVCaptureDevice.authorizeVideo(completion: { (status) in
                            AVCaptureDevice.authorizeAudio(completion: { (status) in
                                if status == .alreadyAuthorized || status == .justAuthorized {
                                    CallManager.shared.startCall(clientId: clientId,
                                                                 clientName: self.username,
                                                                 avatar: "",
                                                                 groupId: groupId,
                                                                 groupToken: response.groupRtcToken,
                                                                 callType: type,
                                                                 isCallGroup: isCallGroup)
                                }
                            })
                        })
                    }
                }
            }
        }
    }
    
    private func convertMessage(_ realmMesssages: [RealmMessage]) -> [MessageModel] {
        var convertedMessages: [MessageModel] = []
        for realmMessage in realmMesssages {
            let message = MessageModel(id: realmMessage.id,
                                       groupID: realmMessage.groupID,
                                       groupType: realmMessage.groupType,
                                       fromClientID: realmMessage.fromClientID,
                                       clientID: realmMessage.clientID,
                                       message: realmMessage.message,
                                       createdAt: realmMessage.createdAt,
                                       updatedAt: realmMessage.updatedAt,
                                       clientWorkspaceDomain: realmMessage.clientWorkspaceDomain)
            convertedMessages.append(message)
        }
        return convertedMessages.sorted(by: { (msg1, msg2) -> Bool in
            return msg1.createdAt < msg2.createdAt
        })
    }
}
