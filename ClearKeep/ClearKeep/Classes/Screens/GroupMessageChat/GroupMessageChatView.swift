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
    
    let groupModel: GroupModel
    
    @State var messages = [MessageModel]()
    @State var messageStr = ""
    @State var isForceProcessKey = true
    
    private let scrollingProxy = ListScrollingProxy()
    
    @State var value: CGFloat = 0
    
    
    init(groupModel: GroupModel) {
        self.groupModel = groupModel
        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
        
    }
    
    var body: some View {
        VStack {
            VStack{
                if #available(iOS 14.0, *) {
                    GeometryReader { reader in
                        ScrollView(.vertical, showsIndicators: false, content: {
                            HStack { Spacer() }
                            ScrollViewReader{reader in
                                VStack(spacing: 20){
                                    ForEach(realmMessages.allMessageInGroup(groupId: groupModel.groupID)) { msg in
                                        // Chat Bubbles...
                                        MessageBubble(msg: msg , isGroup: true)
                                            .id(msg.id)
                                    }
                                }
                                .onChange(of: realmMessages.allMessageInGroup(groupId: groupModel.groupID).count) { _ in
                                    reader.scrollTo(self.getIdLastItem(), anchor: .bottom)
                                }
                                .onAppear(perform: {
                                    reader.scrollTo(self.getIdLastItem(), anchor: .bottom)
                                })
                                .padding([.horizontal,.bottom])
                                .padding(.top, 25)
                            }
                        })
                    }
                }else {
                    GeometryReader { reader in
                        ScrollView(.vertical, showsIndicators: false, content: {
                            HStack { Spacer() }
                            VStack(spacing: 20){
                                ForEach(realmMessages.allMessageInGroup(groupId: groupModel.groupID)) { msg in
                                    // Chat Bubbles...
                                    MessageBubble(msg: msg, isGroup: true)
                                        .id(msg.id)
                                        .background (
                                            ListScrollingHelper(proxy: self.scrollingProxy)
                                        )
                                }
                                .onAppear {
                                    self.reloadData()
                                }
                            }
                            .padding([.horizontal,.bottom])
                            .padding(.top, 25)
                        })
                    }
                }
                
                HStack(spacing: 15){
                    HStack(spacing: 15){
                        TextField("Message", text: $messageStr)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Capsule())
                    
                    // Send Button...
                    // hiding view...
                    if messageStr != ""{
                        Button(action: {
                            // appeding message...
                            // adding animation...
                            withAnimation(.easeIn){
                                self.send()
                            }
                            messageStr = ""
                        }, label: {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color.blue)
                                .padding(.vertical,12)
                                .padding(.leading,12)
                                .padding(.trailing,17)
                                .clipShape(Circle())
                        })
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .animation(.easeOut)
            }
            .navigationBarTitle(Text(groupModel.groupName))
            .onAppear() {
                UserDefaults.standard.setValue(true, forKey: Constants.isChatGroup)
                self.registerWithGroup(groupModel.groupID)
                self.realmMessages.loadSavedData()
                self.groupRealms.loadSavedData()
                self.getMessageInRoom()
            }
            .onDisappear(){
                UserDefaults.standard.setValue(false, forKey: Constants.isChatGroup)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage)) { (obj) in
                if let userInfo = obj.userInfo,
                   let publication = userInfo["publication"] as? Message_MessageObjectResponse {
                    if UserDefaults.standard.bool(forKey: Constants.isChatGroup){
                        self.isForceProcessKey = true
                        self.decryptionMessage(publication: publication)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
                self.getMessageInRoom()
            })
        }
    }
}

extension GroupMessageChatView {
    
    func getIdLastItem() -> String {
        let msgInRoom = realmMessages.allMessageInGroup(groupId: self.groupModel.groupID)
        var id = ""
        if msgInRoom.count > 0 {
            id = msgInRoom[msgInRoom.count - 1].id
        }
        return id
    }
    
    func getMessageInRoom(){
        if groupModel.groupID != 0 {
            Backend.shared.getMessageInRoom(groupModel.groupID , self.realmMessages.getTimeStampPreLastMessage(groupId: groupModel.groupID)) { (result, error) in
                if let result = result {
                    result.lstMessage.forEach { (message) in
                        let filterMessage = self.realmMessages.allMessageInGroup(groupId: message.groupID).filter{$0.id == message.id}
                        if filterMessage.isEmpty {
                            if let ourEncryptionMng = self.ourEncryptionManager,
                               let connectionDb = self.connectionDb {
                                do {
                                    var account: CKAccount?
                                    connectionDb.read { (transaction) in
                                        account = CKAccount.allAccounts(withUsername: message.fromClientID, transaction: transaction).first
                                    }
                                    if let senderAccount = account {
                                        if ourEncryptionMng.senderKeyExistsForUsername(message.fromClientID, deviceId: senderAccount.deviceId, groupId: groupModel.groupID) {
                                            let decryptedData = try ourEncryptionMng.decryptFromGroup(message.message,
                                                                                                      groupId: message.groupID,
                                                                                                      name: message.fromClientID,
                                                                                                      deviceId: UInt32(senderAccount.deviceId))
                                            let messageDecryption = String(data: decryptedData, encoding: .utf8)
                                            print("Message decryption: \(messageDecryption ?? "Empty error")")
                                            
                                            DispatchQueue.main.async {
                                                self.groupRealms.updateLastMessage(groupID: groupModel.groupID, lastMessage: decryptedData, lastMessageAt: message.createdAt, idLastMessage: message.id)
                                                let post = MessageModel(id: message.id,
                                                                        groupID: message.groupID,
                                                                        groupType: message.groupType,
                                                                        fromClientID: message.fromClientID,
                                                                        fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: message.fromClientID, groupID: message.groupID),
                                                                        clientID: message.clientID,
                                                                        message: decryptedData,
                                                                        createdAt: message.createdAt,
                                                                        updatedAt: message.updatedAt)
                                                self.realmMessages.add(message: post)
                                                self.reloadData()
                                            }
                                            
                                            return
                                        }else {
                                            requestKeyInGroup(byGroupId: groupModel.groupID, publication: message)
                                        }
                                    }else {
                                        requestKeyInGroup(byGroupId: groupModel.groupID, publication: message)
                                    }
                                } catch {
                                    print("Decryption message error: \(error)")
                                    requestKeyInGroup(byGroupId: groupModel.groupID, publication: message)
                                }
                            }
                        }
                    }
                    //                    self.reloadData()
                }
            }
        }
    }
    
    private func getUserName(msg: MessageModel) -> String? {
        if let mem = groupModel.lstClientID.filter({ $0.id == msg.fromClientID }).first {
            return mem.username
        }
        return nil
    }
    
    private func reloadData(){
        DispatchQueue.main.async {
            self.realmMessages.loadSavedData()
            self.groupRealms.loadSavedData()
            self.scrollingProxy.scrollTo(.end)
        }
    }
    
    private func send() {
        self.sendMessage(messageStr: $messageStr.wrappedValue)
        //        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    func decryptionMessage(publication: Message_MessageObjectResponse) {
        
        //        requestKeyInGroup(byGroupId: groupModel.groupID, publication: publication)
        if let ourEncryptionMng = self.ourEncryptionManager,
           let connectionDb = self.connectionDb {
            do {
                var account: CKAccount?
                connectionDb.read { (transaction) in
                    account = CKAccount.allAccounts(withUsername: publication.fromClientID, transaction: transaction).first
                }
                if let senderAccount = account {
                    if ourEncryptionMng.senderKeyExistsForUsername(publication.fromClientID, deviceId: senderAccount.deviceId, groupId: groupModel.groupID) {
                        let decryptedData = try ourEncryptionMng.decryptFromGroup(publication.message,
                                                                                  groupId: groupModel.groupID,
                                                                                  name: publication.fromClientID,
                                                                                  deviceId: UInt32(senderAccount.deviceId))
                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
                        print("Message decryption: \(messageDecryption ?? "Empty error")")
                        
                        DispatchQueue.main.async {
                            let post = MessageModel(id: publication.id,
                                                    groupID: publication.groupID,
                                                    groupType: publication.groupType,
                                                    fromClientID: publication.fromClientID,
                                                    fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
                                                    clientID: publication.clientID,
                                                    message: decryptedData,
                                                    createdAt: publication.createdAt,
                                                    updatedAt: publication.updatedAt)
                            self.realmMessages.add(message: post)
                            self.groupRealms.updateLastMessage(groupID: groupModel.groupID, lastMessage: decryptedData, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                            self.reloadData()
                        }
                        
                        return
                    }else {
                        requestKeyInGroup(byGroupId: groupModel.groupID, publication: publication)
                    }
                }else {
                    requestKeyInGroup(byGroupId: groupModel.groupID, publication: publication)
                }
            } catch {
                print("Decryption message error: \(error)")
                requestKeyInGroup(byGroupId: groupModel.groupID, publication: publication)
            }
            //            requestKeyInGroup(byGroupId: self.selectedRoom, publication: publication)
        }
    }
    
    func requestKeyInGroup(byGroupId groupId: Int64, publication: Message_MessageObjectResponse) {
        
        if self.isForceProcessKey {
            Backend.shared.authenticator.requestKeyGroup(byClientId: publication.fromClientID,
                                                         groupId: groupId) {(result, error, response) in
                guard let groupResponse = response else {
                    print("Request prekey \(groupId) fail")
                    return
                }
                self.processSenderKey(byGroupId: groupResponse.groupID,
                                      responseSenderKey: groupResponse.clientKey)
                // decrypt message again
                self.decryptionMessage(publication: publication)
                self.isForceProcessKey = false
            }
        }
    }
    
    private func processSenderKey(byGroupId groupId: Int64,
                                  responseSenderKey: Signal_GroupClientKeyObject) {
        
        let deviceID = 444
        
        if let ourAccountEncryptMng = self.ourEncryptionManager,
           let connectionDb = self.connectionDb {
            // save account infor
            connectionDb.readWrite { (transaction) in
                var account = CKAccount.allAccounts(withUsername: responseSenderKey.clientID, transaction: transaction).first
                if account == nil {
                    account = CKAccount(username: responseSenderKey.clientID, deviceId: Int32(deviceID), accountType: .none)
                    account?.save(with: transaction)
                }
            }
            do {
                let addresss = SignalAddress(name: responseSenderKey.clientID,
                                             deviceId: Int32(deviceID))
                try ourAccountEncryptMng.consumeIncoming(toGroup: groupId,
                                                         address: addresss,
                                                         skdmDtata: responseSenderKey.clientKeyDistribution)
            } catch {
                print("processSenderKey error: \(error)")
            }
        }
    }
    
    func sendMessage(messageStr: String) {
        self.reloadData()
        
        if messageStr.trimmingCharacters(in: .whitespaces).isEmpty {
            return
        }
        
        guard let payload = messageStr.data(using: .utf8) else {
            return
        }
        
        if let myAccount = CKSignalCoordinate.shared.myAccount {
            do {
                guard let encryptedData = try ourEncryptionManager?.encryptToGroup(payload,
                                                                                   groupId: groupModel.groupID,
                                                                                   name: myAccount.username,
                                                                                   deviceId: UInt32(myAccount.deviceId)) else { return }
                Backend.shared.send(encryptedData.data, fromClientId: myAccount.username, groupId: groupModel.groupID, groupType: "group") { (result) in
                    if let result = result {
                        DispatchQueue.main.async {
                            let post = MessageModel(id: result.id,
                                                    groupID: result.groupID,
                                                    groupType: result.groupType,
                                                    fromClientID: result.fromClientID,
                                                    fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: result.fromClientID, groupID: result.groupID),
                                                    clientID: result.clientID,
                                                    message: payload,
                                                    createdAt: result.createdAt,
                                                    updatedAt: result.updatedAt)
                            self.realmMessages.add(message: post)
                            self.groupRealms.updateLastMessage(groupID: groupModel.groupID, lastMessage: payload, lastMessageAt: result.createdAt, idLastMessage: result.id)
                            self.reloadData()
                        }
                    }
                    print("Send message to group \(groupModel.groupID) result")
                }
            } catch {
                print("Send message error: \(error)")
            }
        }
    }
    
    func registerWithGroup(_ groupId: Int64) {
        
        if let group = self.groupRealms.filterGroup(groupId: groupId) {
            if !group.isRegister {
                if let myAccount = CKSignalCoordinate.shared.myAccount , let ourAccountEncryptMng = self.ourEncryptionManager {
                    let userName = myAccount.username
                    let deviceID = Int32(555)
                    let address = SignalAddress(name: userName, deviceId: deviceID)
                    let groupSessionBuilder = SignalGroupSessionBuilder(context: ourAccountEncryptMng.signalContext)
                    let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
                    
                    do {
                        let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
                        Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                                   clientId: userName,
                                                                   deviceId: deviceID,
                                                                   senderKeyData: signalSKDM.serializedData()) { (result, error) in
                            print("Register group with result: \(result)")
                            if result {
                                self.groupRealms.registerGroup(groupId: groupId)
                            }
                        }
                        
                    } catch {
                        print("Register group error: \(error)")
                        
                    }
                }
            }
        }
    }
    
    func requestAllKeyInGroup(byGroupId groupId: Int64) {
        Backend.shared.authenticator.requestAllKeyInGroup(byGroup: groupId) {(result, error, response) in
            guard let allKeyGroupResponse = response else {
                print("Request prekey \(groupId) fail")
                return
            }
            
            if let ourAccountEncryptMng = self.ourEncryptionManager {
                for groupSenderKeyObj in allKeyGroupResponse.lstClientKey {
                    // check processed senderKey
                    if !ourAccountEncryptMng.senderKeyExistsForUsername(groupSenderKeyObj.clientID,
                                                                        deviceId: groupSenderKeyObj.deviceID,
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

//struct GroupMessageChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupMessageChatView(GroupModel()).environmentObject(RealmGroup()).environmentObject(RealmMessages())
//    }
//}
