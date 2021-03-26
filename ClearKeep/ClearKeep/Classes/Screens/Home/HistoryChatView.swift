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
    
    @State var pushActive = false
    @State var isForceProcessKeyInGroup = true
    @State var allGroup = [GroupModel]()
    @EnvironmentObject var viewRouter: ViewRouter

    @State var showInviteMemberGroup = false
    @State private var recentCreatedGroupChatID: Int64 = 0
    
    var body: some View {
        
        NavigationView {
            VStack {
                NavigationLink(
                    destination: InviteMemberGroup(showInviteMemberGroup: $showInviteMemberGroup, recentCreatedGroupChatID: $recentCreatedGroupChatID),
                    isActive: $showInviteMemberGroup
                ) {
                    EmptyView()
                }
                
                if self.groupRealms.all.isEmpty {
                    Text("Start a conversation by clicking Chat or Create Room")
                        .font(.title)
                        .foregroundColor(.gray)
                        .lineLimit(nil)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
                } else {
                    List(self.groupRealms.all , id: \.groupID){ group in
                        
                        if group.groupType == "peer" {
                            let viewPeer = MessageChatView(clientId: viewModel.getClientIdFriend(listClientID: group.lstClientID.map{$0.id}),
                                                           groupID : group.groupID,
                                                           userName: viewModel.getPeerReceiveName(inGroup: group),
                                                           groupType: group.groupType).environmentObject(self.groupRealms).environmentObject(self.messsagesRealms)
//                            NavigationLink(destination: viewPeer, tag: "\(group.groupID)", selection: self.$recentCreatedGroupChatID) {
                            NavigationLink(destination: viewPeer) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                if group.lastMessage.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text(viewModel.getGroupName(group: group))
                                    }
                                } else {
                                    VStack(alignment: .leading) {
                                        Text(viewModel.getPeerReceiveName(inGroup: group))
                                        Text(viewModel.getMessage(data: group.lastMessage))
                                            .lineLimit(1)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        } else {
                            
                            let viewGroup = GroupMessageChatView(groupModel: group).environmentObject(self.groupRealms).environmentObject(self.messsagesRealms)
                            //                            NavigationLink(destination: viewGroup, tag: "\(group.groupID)", selection: self.$recentCreatedGroupChatID) {
                                                        NavigationLink(destination: viewGroup) {
                                Image(systemName: "person.2.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                if group.lastMessage.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text(viewModel.getGroupName(group: group))
                                    }
                                } else {
                                    VStack(alignment: .leading) {
                                        Text(viewModel.getGroupName(group: group))
                                        Text(viewModel.getMessage(data: group.lastMessage))
                                            .lineLimit(1)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onAppear(){
                UserDefaults.standard.setValue(false, forKey: Constants.isChatRoom)
                UserDefaults.standard.setValue(false, forKey: Constants.isChatGroup)
                self.ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
                self.viewModel.start(ourEncryptionManager: self.ourEncryptionManager)
                self.reloadData()
                self.getJoinedGroup()
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(leading: Text("Chat"), trailing:  Button("Create Group"){
                //viewRouter.current = .inviteMember
                self.showInviteMemberGroup = true
            })
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Notification), perform: { (obj) in
            self.didReceiveMessageGroup(userInfo: obj.userInfo)
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage), perform: { (obj) in
            if let userInfo = obj.userInfo,
               let publication = userInfo["publication"] as? Message_MessageObjectResponse {
                
                let isChatRoom = UserDefaults.standard.bool(forKey: Constants.isChatRoom)
                let isChatGroup = UserDefaults.standard.bool(forKey: Constants.isChatGroup)
                
                if publication.groupType == "peer" {
                    if !isChatRoom && !isChatGroup {
                        self.viewModel.requestBundleRecipient(byClientId: publication
                                                                .fromClientID) {
                            self.didReceiveMessagePeer(userInfo: userInfo)
                        }
                    }
                } else {
                    if !isChatRoom && !isChatGroup {
                        self.isForceProcessKeyInGroup = true
                        self.decryptionMessage(publication: publication)
                    }
                }
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
                self.getJoinedGroup()
        })
    }
    
}

extension HistoryChatView {
    
    func reloadData(){
        DispatchQueue.main.async {
            self.groupRealms.loadSavedData()
            self.messsagesRealms.loadSavedData()
        }
    }
    
    func getJoinedGroup(){
        print("getJoinnedGroup")
        
        Backend.shared.getJoinnedGroup { (result, error) in
            DispatchQueue.main.async {
            if let result = result {
                result.lstGroup.forEach { (groupResponse) in
                    if let group = self.groupRealms.filterGroup(groupId: groupResponse.groupID){
                        if group.idLastMessage == groupResponse.lastMessage.id {
                        } else {
                            self.updateLastMessageInGroup(groupResponse: groupResponse)
                        }
                    } else {
//                        DispatchQueue.main.async {
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
                                                        lastMessageAt: 0,
                                                        lastMessage: Data(),
                                                        idLastMessage: "",
                                                        timeSyncMessage: 0)
                            self.groupRealms.add(group: groupModel)
                            self.registerWithGroup(groupResponse.groupID)
                            self.updateLastMessageInGroup(groupResponse: groupResponse)
//                        }
                    }
                }
            }
            self.reloadData()
            }
        }
    }
    
    func updateLastMessageInGroup(groupResponse: Group_GroupObjectResponse){
        // break last message with time login
        if let loginDate = UserDefaults.standard.value(forKey: Constants.User.loginDate) as? Date {
            let updateAt = NSDate(timeIntervalSince1970: TimeInterval(groupResponse.lastMessage.createdAt/1000))
            if loginDate.compare(updateAt as Date) == ComparisonResult.orderedDescending {
                return
            }
        }
        
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
                                                       fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: lastMessage.fromClientID, groupID: lastMessage.groupID),
                                                       clientID: lastMessage.clientID,
                                                       message: decryptedData,
                                                       createdAt: lastMessage.createdAt,
                                                       updatedAt: lastMessage.updatedAt)
                            self.messsagesRealms.add(message: message)
                            self.groupRealms.updateLastMessage(groupID: groupResponse.groupID, lastMessage: decryptedData, lastMessageAt: groupResponse.lastMessageAt, idLastMessage: groupResponse.lastMessage.id)
                            self.groupRealms.sort()
                            self.reloadData()
                        }
                    } catch {
                        print("decrypt message error: ---- getJoinnedGroup")
                    }
                }
        } else {
            self.decryptionMessage(publication: messageResponse)
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
        
//        requestKeyInGroup(byGroupId: groupModel.groupID, publication: publication)
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
                                                    fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
                                                    clientID: publication.clientID,
                                                    message: decryptedData,
                                                    createdAt: publication.createdAt,
                                                    updatedAt: publication.updatedAt)
                            self.messsagesRealms.add(message: post)
                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: decryptedData, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                            self.groupRealms.sort()
                            self.reloadData()
                        }
                        
                        return
                    }else {
                        requestKeyInGroup(byGroupId: publication.groupID, publication: publication)
                    }
                }else {
                    requestKeyInGroup(byGroupId: publication.groupID, publication: publication)
                }
            } catch {
                print("Decryption message error: \(error)")
                requestKeyInGroup(byGroupId: publication.groupID, publication: publication)
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
    
    func requestKeyInGroup(byGroupId groupId: Int64, publication: Message_MessageObjectResponse) {
         
        if self.isForceProcessKeyInGroup {
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
                self.isForceProcessKeyInGroup = false
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
                                                fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
                                                clientID: publication.clientID,
                                                message: decryptedData,
                                                createdAt: publication.createdAt,
                                                updatedAt: publication.updatedAt)
                        DispatchQueue.main.async {
                            self.messsagesRealms.add(message: post)
                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: decryptedData, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                            self.groupRealms.sort()
                            self.reloadData()
                            
                            print("message decypt realm: ----- \(viewModel.getMessage(data: self.groupRealms.all[0].lastMessage))")
                            
                            
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: message[0].message, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                            self.groupRealms.sort()
                            self.reloadData()
                        }
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        let messageError = "unable to decrypt this message".data(using: .utf8) ?? Data()
                        
                        let post = MessageModel(id: publication.id,
                                                groupID: publication.groupID,
                                                groupType: publication.groupType,
                                                fromClientID: publication.fromClientID,
                                                fromDisplayName: self.groupRealms.getDisplayNameSenderMessage(fromClientId: publication.fromClientID, groupID: publication.groupID),
                                                clientID: publication.clientID,
                                                message: messageError,
                                                createdAt: publication.createdAt,
                                                updatedAt: publication.updatedAt)
                        self.messsagesRealms.add(message: post)
                        self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: messageError, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
                        self.groupRealms.sort()
                        self.reloadData()
                    }
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
