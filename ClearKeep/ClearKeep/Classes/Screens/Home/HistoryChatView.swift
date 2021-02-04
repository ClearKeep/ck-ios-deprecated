//
//  HistoryChatView.swift
//  ClearKeep
//
//  Created by Seoul on 11/18/20.
//

import SwiftUI

struct HistoryChatView: View {
    
    @ObservedObject var viewModel = HistoryChatViewModel()
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var messsagesRealms : RealmMessages
    
    @State var ourEncryptionManager: CKAccountSignalEncryptionManager?
    let connectionDb = CKDatabaseManager.shared.database?.newConnection()
    
    //    init(){
    //        ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
    //    }
    
    @State var pushActive = false
    
    var body: some View {
        
        NavigationView {
            List(groupRealms.all , id: \.groupID){ group in
                let viewPeer = MessageChatView(clientId: viewModel.getClientIdFriend(listClientID: group.lstClientID.map{$0.id}),
                                               groupID : group.groupID,
                                               userName: viewModel.getGroupName(group: group),
                                               groupType: group.groupType).environmentObject(self.groupRealms).environmentObject(self.messsagesRealms)
                
                let viewGroup = GroupMessageChatView(groupModel: group).environmentObject(self.groupRealms).environmentObject(self.messsagesRealms)
                
                if group.groupType == "peer" {
                    NavigationLink(destination:  viewPeer) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                        VStack(alignment: .leading) {
                            Text(viewModel.getGroupName(group: group))
                            Text(viewModel.getMessage(data: group.lastMessage))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }else {
                    NavigationLink(destination:  viewGroup) {
                        Image(systemName: "person.2.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                        VStack(alignment: .leading) {
                            Text(viewModel.getGroupName(group: group))
                            Text(viewModel.getMessage(data: group.lastMessage))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .onAppear(){
                UserDefaults.standard.setValue(false, forKey: Constants.isChatRoom)
                UserDefaults.standard.setValue(false, forKey: Constants.isChatGroup)
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(leading: Text("Chat"), trailing: NavigationLink(
                destination: CreateRoomView(isPresentModel: self.$pushActive),
                isActive: self.$pushActive
            ) {
                Text("CreateRoom")
            }
            .isDetailLink(false))
        }.onAppear(){
            self.ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
            self.viewModel.start(ourEncryptionManager: self.ourEncryptionManager)
            DispatchQueue.main.async {
                self.groupRealms.loadSavedData()
                self.messsagesRealms.loadSavedData()
            }
            self.getJoinedGroup()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Notification), perform: { (obj) in
            self.didReceiveMessageGroup(userInfo: obj.userInfo)
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage), perform: { (obj) in
            if let userInfo = obj.userInfo,
               let publication = userInfo["publication"] as? Message_MessageObjectResponse {
                
                if publication.groupType == "peer" {
                    if !UserDefaults.standard.bool(forKey: Constants.isChatRoom) {
                        self.viewModel.requestBundleRecipient(byClientId: publication
                                                                .fromClientID) {
                            self.didReceiveMessagePeer(userInfo: userInfo)
                        }
                    }
                } else {
                    if !UserDefaults.standard.bool(forKey: Constants.isChatGroup) {
                        self.decryptionMessage(publication: publication)
                    }
                }
            }
        })
    }
    
}

extension HistoryChatView {
    func getJoinedGroup(){
        print("getJoinnedGroup")
        
        Backend.shared.getJoinnedGroup { (result, error) in
            if let result = result {
                result.lstGroup.forEach { (groupResponse) in
                    if let group = self.groupRealms.filterGroup(groupId: groupResponse.groupID){
                        if group.lastMessageAt == groupResponse.lastMessageAt {
                        } else {
                            let lastMessageResponse = groupResponse.lastMessage
                            var messageResponse = Message_MessageObjectResponse()
                            messageResponse.id = lastMessageResponse.id
                            messageResponse.groupID = lastMessageResponse.groupID
                            messageResponse.groupType = lastMessageResponse.groupType
                            messageResponse.fromClientID = lastMessageResponse.fromClientID
                            messageResponse.clientID = lastMessageResponse.clientID
                            messageResponse.message = lastMessageResponse.message
                            messageResponse.createdAt = lastMessageResponse.createdAt
                            messageResponse.updatedAt = lastMessageResponse.updatedAt
                            messageResponse.unknownFields = lastMessageResponse.unknownFields
                            
                            if groupResponse.groupType == "peer" {
                                self.viewModel.requestBundleRecipient(byClientId: messageResponse
                                                                        .fromClientID) {
                                    if let ourEncryptionMng = self.ourEncryptionManager {
                                        do {
                                            let decryptedData = try ourEncryptionMng.decryptFromAddress(groupResponse.lastMessage.message,
                                                                                                        name: groupResponse.lastMessage.fromClientID,
                                                                                                        deviceId: UInt32(111))
                                            let lastMessage = groupResponse.lastMessage
                                            DispatchQueue.main.async {
                                                let message = MessageModel(id: lastMessage.id,
                                                                           groupID: lastMessage.groupID,
                                                                           groupType: lastMessage.groupType,
                                                                           fromClientID: lastMessage.fromClientID,
                                                                           clientID: lastMessage.clientID,
                                                                           message: decryptedData,
                                                                           createdAt: lastMessage.createdAt,
                                                                           updatedAt: lastMessage.updatedAt)
                                                self.messsagesRealms.add(message: message)
                                                self.groupRealms.updateLastMessage(groupID: group.groupID, lastMessage: decryptedData, lastMessageAt: groupResponse.createdAt)
                                            }
                                        } catch {
                                            print("decrypt message error: ---- getJoinnedGroup")
                                        }
                                    }
                                    
                                }
                            } else {
                                self.decryptionMessage(publication: messageResponse)
                            }
                            
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            let lstClientID = groupResponse.lstClient.map{ GroupMember(id: $0.id, username: $0.displayName)}
                            let groupModel = GroupModel(groupID: groupResponse.groupID,
                                                        groupName: groupResponse.groupName,
                                                        groupToken: groupResponse.groupRtcToken,
                                                        groupAvatar: groupResponse.groupAvatar,
                                                        groupType: groupResponse.groupType,
                                                        createdByClientID: groupResponse.createdByClientID,
                                                        createdAt: groupResponse.createdAt,
                                                        updatedByClientID: groupResponse.updatedByClientID,
                                                        lstClientID: lstClientID,
                                                        updatedAt: groupResponse.updatedAt,
                                                        lastMessageAt: groupResponse.lastMessageAt,
                                                        lastMessage: Data())
                            self.groupRealms.add(group: groupModel)
                        }
                    }
                }
            }
        }
    }
    
    func didReceiveMessageGroup(userInfo: [AnyHashable : Any]?) {
        if let userInfo = userInfo,
           let publication = userInfo["publication"] as? Notification_NotifyObjectResponse {
            if publication.notifyType == "new-peer" ||  publication.notifyType == "new-group" {
                self.getJoinedGroup()
            }
        }
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
                    if ourEncryptionMng.senderKeyExistsForUsername(publication.fromClientID, deviceId: senderAccount.deviceId, groupId: publication.groupID) {
                        let decryptedData = try ourEncryptionMng.decryptFromGroup(publication.message,
                                                                                  groupId: publication.groupID,
                                                                                  name: publication.fromClientID,
                                                                                  deviceId: UInt32(senderAccount.deviceId))
                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
                        print("Message decryption: \(messageDecryption ?? "Empty error")")
                        
                        DispatchQueue.main.async {
                            let post = MessageModel(id: publication.id,
                                                    groupID: publication.groupID,
                                                    groupType: publication.groupType,
                                                    fromClientID: publication.fromClientID,
                                                    clientID: publication.clientID,
                                                    message: decryptedData,
                                                    createdAt: publication.createdAt,
                                                    updatedAt: publication.updatedAt)
                            self.messsagesRealms.add(message: post)
                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: decryptedData, lastMessageAt: publication.createdAt)
                        }
                        return
                    }
                }
            } catch {
                print("Decryption message error: \(error)")
                requestKeyInGroup(byGroupId: publication.groupID, publication: publication)
            }
            requestKeyInGroup(byGroupId: publication.groupID, publication: publication)
        }
    }
    
    func requestKeyInGroup(byGroupId groupId: Int64, publication: Message_MessageObjectResponse) {
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
    
    private func processSenderKey(byGroupId groupId: Int64,
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
    
    
    func didReceiveMessagePeer(userInfo: [AnyHashable : Any]?) {
        if let userInfo = userInfo,
           let publication = userInfo["publication"] as? Message_MessageObjectResponse{
            
            //            Backend.shared.authenticator
            //                .requestKey(byClientId: publication.fromClientID) {(result, error, response) in
            //                    if let response = response {
            if let ourEncryptionMng = self.ourEncryptionManager {
                do {
                    
                    let message = self.messsagesRealms.all.filter{$0.id == publication.id}
                    
                    if message.isEmpty {
                        let decryptedData = try ourEncryptionMng.decryptFromAddress(publication.message,
                                                                                    name: publication.fromClientID,
                                                                                    deviceId: UInt32(555))
                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
                        print("Message decryption peer: \(messageDecryption ?? "Empty error")")
                        let post = MessageModel(id: publication.id,
                                                groupID: publication.groupID,
                                                groupType: publication.groupType,
                                                fromClientID: publication.fromClientID,
                                                clientID: publication.clientID,
                                                message: decryptedData,
                                                createdAt: publication.createdAt,
                                                updatedAt: publication.updatedAt)
                        DispatchQueue.main.async {
                            self.messsagesRealms.add(message: post)
                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: decryptedData, lastMessageAt: publication.createdAt)
                            
                            print("message decypt realm: ----- \(viewModel.getMessage(data: self.groupRealms.all[0].lastMessage))")
                            
                            
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: message[0].message, lastMessageAt: publication.createdAt)
                        }
                    }
                    
                } catch {
                    print("Decryption message error: \(error)")
                }
            }
        }
    }
    
    
    
}

struct HistoryChatView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryChatView().environmentObject(RealmGroups()).environmentObject(RealmMessages())
    }
}
