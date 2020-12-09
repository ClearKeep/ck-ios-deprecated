//
//  GroupMessageChatView.swift
//  ClearKeep
//
//  Created by VietAnh on 11/5/20.
//

import SwiftUI

struct GroupMessageChatView: View {
    @State private var nextMessage: String = ""
    
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var realmMessages : RealmMessages
    
    var ourEncryptionManager: CKAccountSignalEncryptionManager?
    var recipientDeviceId: UInt32 = 0
    let connectionDb = CKDatabaseManager.shared.database?.newConnection()
    
    private var groupName: String = ""
    
    @State var messages = [MessageModel]()
    
    
    private let selectedRoom: String
    
    init(groupId: String, groupName: String) {
        self.selectedRoom = groupId
        self.groupName = groupName
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
    }
    
    var body: some View {
        VStack {
            List(messages, id: \.id) { model in
                MessageView(mesgModel: model, chatWithUserID: "", chatWithUserName: "" , isGroup: true)
            }
            .navigationBarTitle(Text(self.groupName))
            HStack {
                TextFieldContent(key: "Next message", value: self.$nextMessage)
                Button( action: {
                    self.send()
                }){
                    Image(systemName: "paperplane")
                }.padding(.trailing)
            }.onAppear() {
                self.requestAllKeyInGroup(byGroupId: self.selectedRoom)
                self.registerWithGroup(self.selectedRoom)
                self.reloadData()
                self.realmMessages.loadSavedData()
                self.groupRealms.loadSavedData()
                self.getMessageInRoom()
                
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage)) { (obj) in
                if let userInfo = obj.userInfo,
                   let publication = userInfo["publication"] as? Message_MessageObjectResponse {
                    if !self.realmMessages.isExistMessage(msgId: publication.id) {
                        self.decryptionMessage(publication: publication)
                    }
                }
            }
        }
    }
}

extension GroupMessageChatView {
    
    func getMessageInRoom(){
        if !self.selectedRoom.isEmpty {
            Backend.shared.getMessageInRoom(self.selectedRoom , self.realmMessages.getTimeStampPreLastMessage(groupId: self.selectedRoom)) { (result, error) in
                if let result = result {
                    result.lstMessage.forEach { (message) in
                        let filterMessage = self.realmMessages.allMessageInGroup(groupId: message.groupID).filter{$0.id == message.id}
                        if filterMessage.isEmpty {
                            if let ourEncryptionMng = self.ourEncryptionManager {
                                do {
                                    let decryptedData = try ourEncryptionMng.decryptFromAddress(message.message,
                                                                                                name: message.fromClientID,
                                                                                                deviceId: UInt32(111))
                                    let messageDecryption = String(data: decryptedData, encoding: .utf8)
                                    print("Message decryption: \(messageDecryption ?? "Empty error")")
                                    let post = MessageModel(id: message.id,
                                                            groupID: message.groupID,
                                                            groupType: message.groupType,
                                                            fromClientID: message.fromClientID,
                                                            clientID: message.clientID,
                                                            message: decryptedData,
                                                            createdAt: message.createdAt,
                                                            updatedAt: message.updatedAt)
                                    self.realmMessages.add(message: post)
                                } catch {
                                    print("Decryption message error: \(error)")
                                }
                            }
                        }
                    }
                    self.reloadData()
                }
            }
        }
    }
    
    private func reloadData(){
        self.messages = self.realmMessages.allMessageInGroup(groupId: self.selectedRoom)
    }
    
    private func send() {
        self.sendMessage(messageStr: $nextMessage.wrappedValue)
        nextMessage = ""
    }
    
    
    func decryptionMessage(publication: Message_MessageObjectResponse) {
        if let ourEncryptionMng = self.ourEncryptionManager,
           let connectionDb = self.connectionDb {
            do {
                var account: CKAccount?
                connectionDb.read { (transaction) in
                    account = CKAccount.allAccounts(withUsername: publication.fromClientID, transaction: transaction).first
                }
                if let senderAccount = account {
                    if ourEncryptionMng.senderKeyExistsForUsername(publication.fromClientID, deviceId: senderAccount.deviceId, groupId: selectedRoom) {
                        let decryptedData = try ourEncryptionMng.decryptFromGroup(publication.message,
                                                                                  groupId: self.selectedRoom,
                                                                                  name: publication.fromClientID,
                                                                                  deviceId: UInt32(111))
                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
                        print("Message decryption: \(messageDecryption ?? "Empty error")")
                        
                        self.groupRealms.updateLastMessage(groupID: self.selectedRoom, lastMessage: decryptedData)
                        let post = MessageModel(id: publication.id,
                                                groupID: publication.groupID,
                                                groupType: publication.groupType,
                                                fromClientID: publication.fromClientID,
                                                clientID: publication.clientID,
                                                message: decryptedData,
                                                createdAt: publication.createdAt,
                                                updatedAt: publication.updatedAt)
                        self.realmMessages.add(message: post)
                        self.reloadData()
                        return
                    }
                }
            } catch {
                print("Decryption message error: \(error)")
                requestKeyInGroup(byGroupId: self.selectedRoom, publication: publication)
            }
            requestKeyInGroup(byGroupId: self.selectedRoom, publication: publication)
        }
    }
    
    func requestKeyInGroup(byGroupId groupId: String, publication: Message_MessageObjectResponse) {
        Backend.shared.authenticator.requestKeyGroup(byClientId: publication.fromClientID,
                                                     groupId: groupId) {(result, error, response) in
            guard let groupResponse = response else {
                print("Request prekey \(groupId) fail")
                return
            }
            if let ourEncryptionMng = self.ourEncryptionManager {
                if !ourEncryptionMng.senderKeyExistsForUsername(groupResponse.clientKey.clientID,
                                                                deviceId: groupResponse.clientKey.deviceID,
                                                                groupId: groupId) {
                    self.processSenderKey(byGroupId: groupResponse.groupID,
                                          responseSenderKey: groupResponse.clientKey)
                    
                    // decrypt message again
                    self.decryptionMessage(publication: publication)
                }
            }
        }
    }
    
    private func processSenderKey(byGroupId groupId: String,
                                  responseSenderKey: Signal_GroupClientKeyObject) {
        if let ourAccountEncryptMng = self.ourEncryptionManager,
           let connectionDb = self.connectionDb {
            // save account infor
            connectionDb.readWrite { (transaction) in
                var account = CKAccount.allAccounts(withUsername: responseSenderKey.clientID, transaction: transaction).first
                if account == nil {
                    account = CKAccount(username: responseSenderKey.clientID, deviceId: responseSenderKey.deviceID, accountType: .none)
                    account?.save(with: transaction)
                }
            }
            do {
                let addresss = SignalAddress(name: responseSenderKey.clientID,
                                             deviceId: responseSenderKey.deviceID)
                try ourAccountEncryptMng.consumeIncoming(toGroup: groupId,
                                                         address: addresss,
                                                         skdmDtata: responseSenderKey.clientKeyDistribution)
            } catch {
                print("processSenderKey error: \(error)")
            }
        }
    }
    
    func sendMessage(messageStr: String) {
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            do {
                guard let encryptedData = try ourEncryptionManager?.encryptToGroup(payload,
                                                                                   groupId: self.selectedRoom,
                                                                                   name: myAccount.username,
                                                                                   deviceId: UInt32(myAccount.deviceId)) else { return }
                Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, groupId: self.selectedRoom, groupType: "group") { (result) in
                    if let result = result {
                        let post = MessageModel(id: result.id,
                                                groupID: result.groupID,
                                                groupType: result.groupType,
                                                fromClientID: result.fromClientID,
                                                clientID: result.clientID,
                                                message: payload,
                                                createdAt: result.createdAt,
                                                updatedAt: result.updatedAt)
                        self.realmMessages.add(message: post)
                        self.groupRealms.updateLastMessage(groupID: self.selectedRoom, lastMessage: payload)
                        self.reloadData()
                    }
                    print("Send message to group \(self.selectedRoom) result")
                }
            } catch {
                print("Send message error: \(error)")
            }
        }
    }
    
    func registerWithGroup(_ groupId: String) {
        if let myAccount = CKSignalCoordinate.shared.myAccount , let ourAccountEncryptMng = self.ourEncryptionManager {
            let userName = myAccount.username
            let deviceID = Int32(myAccount.deviceId)
            
            let address = SignalAddress(name: userName, deviceId: deviceID)
            let groupSessionBuilder = SignalGroupSessionBuilder(context: ourAccountEncryptMng.signalContext)
            let senderKeyName = SignalSenderKeyName(groupId: groupId, address: address)
            do {
                let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
                Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                           clientId: userName,
                                                           deviceId: deviceID,
                                                           senderKeyData: signalSKDM.serializedData()) { (result, error) in
                    print("Register group with result: \(result)")
                    if result {
                        Backend.shared.signalSubscrible(clientId: userName)
                    }
                }
                
            } catch {
                print("Register group error: \(error)")
                
            }
        }
    }
    
    func requestAllKeyInGroup(byGroupId groupId: String) {
        Backend.shared.authenticator.requestAllKeyInGroup(byGroup: groupId) {(result, error, response) in
            guard let allKeyGroupResponse = response else {
                print("Request prekey \(groupId) fail")
                return
            }
            
            if let ourAccountEncryptMng = self.ourEncryptionManager {
                for groupSenderKeyObj in allKeyGroupResponse.lstClientKey {
                    // check processed senderKey
                    if !ourAccountEncryptMng.senderKeyExistsForUsername(groupSenderKeyObj.clientID,
                                                                        deviceId: 111,
                                                                        groupId: groupId) {
                        self.processSenderKey(byGroupId: allKeyGroupResponse.groupID,
                                              responseSenderKey: groupSenderKeyObj)
                    }
                }
                print("processPreKeyBundle group finished: \(allKeyGroupResponse.lstClientKey.count) members")
            }
        }
    }
    
    
    
    
}

struct GroupMessageChatView_Previews: PreviewProvider {
    static var previews: some View {
        GroupMessageChatView(groupId: "" , groupName: "").environmentObject(RealmGroup()).environmentObject(RealmMessages())
    }
}
