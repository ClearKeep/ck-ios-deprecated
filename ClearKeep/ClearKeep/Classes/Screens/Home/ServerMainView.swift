//
//  ServerMainView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/22/21.
//

import SwiftUI

struct ServerMainView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var messsagesRealms : RealmMessages
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel = ServerMainViewModel()
    
    @State var ourEncryptionManager: CKAccountSignalEncryptionManager?
    @State var pushActive = false
    @State var isForceProcessKeyInGroup = true
    @State var allGroup = [GroupModel]()
    
    @State private var searchText: String = ""
    @State private var numberGroupChat: Int = 4
    @State private var numberDirectMessages: Int = 5
    
    @State private var isGroupChatExpanded: Bool = true
    @State private var isDirectMessageExpanded: Bool = true
    
    @State private var isShowingPeopleView = false
    @State private var isShowingInviteMemberGroupView = false
    
    @Binding var isShowingServerDetailView: Bool
    
    let connectionDb = CKDatabaseManager.shared.database?.newConnection()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 4)
                
                HStack {
                    Text("CK Development")
                        .font(AppTheme.fonts.displaySmallBold.font)
                        .foregroundColor(AppTheme.colors.black.color)
                    Spacer()
                    Button(action: {
                        self.isShowingServerDetailView.toggle()
                    }, label: {
                        Image("Hamburger")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24, alignment: .center)
                            .foregroundColor(AppTheme.colors.gray1.color)
                    })
                }
                
                //WrappedTextFieldWithLeftIcon("Search", leftIconName: "Search", shouldShowBorderWhenFocused: false, keyboardType: UIKeyboardType.default, text: $searchText, errorMessage: .constant(""))
                
                SearchBar(text: $searchText) { (changed) in
                    if changed {
                    } else {
                        //self.searchUser(searchText)
                    }
                }
                
                Button(action: {}, label: {
                    HStack {
                        Image("Notes")
                            .resizable()
                            .foregroundColor(AppTheme.colors.gray1.color)
                            .frame(width: 18, height: 18, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        Text("Notes")
                            .font(AppTheme.fonts.linkMedium.font)
                            .foregroundColor(AppTheme.colors.gray1.color)
                        Spacer()
                    }
                })
                
                groupChatSection()
                
                directMessageSection()
                
                Spacer()
            }
            .padding()
        })
        .onTapGesture {
            self.hideKeyboard()
        }
        .onAppear(){
            UserDefaults.standard.setValue(false, forKey: Constants.isChatRoom)
            UserDefaults.standard.setValue(false, forKey: Constants.isChatGroup)
            self.ourEncryptionManager = CKSignalCoordinate.shared.ourEncryptionManager
            self.viewModel.start(ourEncryptionManager: self.ourEncryptionManager)
            self.reloadData()
            self.getJoinedGroup()
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

extension ServerMainView {
    
    private func filteredGroupRealm(isForPeer: Bool) -> [GroupModel] {
        let items = self.groupRealms.all.filter { (groupModel) -> Bool in
            if isForPeer {
                return groupModel.groupType == "peer"
            } else {
                return groupModel.groupType != "peer"
            }
        }
        
        return items
    }
    
    private func groupChatDestination(groupModel: GroupModel) -> some View {
        Group {
            if groupModel.groupType == "peer" {
                MessageChatView(clientId: viewModel.getClientIdFriend(listClientID: groupModel.lstClientID.map{$0.id}),
                                groupID : groupModel.groupID,
                                userName: viewModel.getPeerReceiveName(inGroup: groupModel),
                                groupType: groupModel.groupType).environmentObject(self.groupRealms).environmentObject(self.messsagesRealms)
            } else {
                GroupMessageChatView(groupModel: groupModel).environmentObject(self.groupRealms).environmentObject(self.messsagesRealms)
            }
        }
    }
    
    private func groupChatSection() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Group Chat (\(filteredGroupRealm(isForPeer: false).count))")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.gray1.color)
                
                Button(action: {
                    self.isGroupChatExpanded.toggle()
                }, label: {
                    Image(isGroupChatExpanded ? "Chev-down" : "Chev-up")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18, height: 18, alignment: .center)
                        .foregroundColor(AppTheme.colors.gray1.color)
                        .padding(.all, 6)
                })
                
                Spacer()
                
                NavigationLink(destination: InviteMemberGroup(isPresentModel:$isShowingInviteMemberGroupView).environmentObject(self.groupRealms).environmentObject(self.messsagesRealms), isActive: $isShowingInviteMemberGroupView) {
                    Image("Plus")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(AppTheme.colors.gray1.color)
                }
            }
            
            if isGroupChatExpanded && !filteredGroupRealm(isForPeer: false).isEmpty {
                listGroupChat()
                    .padding(.leading, 16)
            }
        }
    }
    
    private func listGroupChat() -> some View {
        Group {
            ForEach(self.filteredGroupRealm(isForPeer: false), id: \.groupID) { group in
                NavigationLink(destination: groupChatDestination(groupModel: group)) {
                    Text(viewModel.getGroupName(group: group))
                        .font(AppTheme.fonts.linkSmall.font)
                        .foregroundColor(AppTheme.colors.gray1.color)
                    
                    Spacer()
                    
                    if viewModel.getGroupUnreadMessageNumber(group: group) > 0 {
                        Text("\(viewModel.getGroupUnreadMessageNumber(group: group))")
                            .font(AppTheme.fonts.textXSmall.font)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                            .frame(width: 24, height: 24, alignment: .center)
                            .background(AppTheme.colors.secondary.color)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    private func directMessageSection() -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Direct Messages (\(filteredGroupRealm(isForPeer: true).count))")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.gray1.color)
                
                Button(action: {
                    self.isDirectMessageExpanded.toggle()
                }, label: {
                    Image(isDirectMessageExpanded ? "Chev-down" : "Chev-up")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 18, height: 18, alignment: .center)
                        .foregroundColor(AppTheme.colors.gray1.color)
                        .padding(.all, 6)
                })
                
                Spacer()
                
                NavigationLink(destination: PeopleView().environmentObject(self.groupRealms).environmentObject(self.messsagesRealms), isActive: $isShowingPeopleView) {
                    Image("Plus")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(AppTheme.colors.gray1.color)
                }
            }
            
            if isDirectMessageExpanded && !filteredGroupRealm(isForPeer: true).isEmpty {
                listDirectMessage()
                    .padding(.leading, 16)
            }
        }
    }
    
    private func listDirectMessage() -> some View {
        Group {
            ForEach(self.filteredGroupRealm(isForPeer: true), id: \.groupID) { group in
                NavigationLink(destination:  groupChatDestination(groupModel: group)) {
                    ChannelUserAvatar(avatarSize: 24, statusSize: 8, text: viewModel.getGroupName(group: group), font: AppTheme.fonts.linkSmall.font, image: viewModel.getGroupAvatarImage(group: group), status: viewModel.getGroupOnlineStatus(group: group), gradientBackgroundType: .accent)
                    
                    Text(viewModel.getGroupName(group: group))
                        .font(AppTheme.fonts.linkSmall.font)
                        .foregroundColor(AppTheme.colors.gray1.color)
                    
                    Spacer()
                    
                    if viewModel.getGroupUnreadMessageNumber(group: group) > 0 {
                        Text("\(viewModel.getGroupUnreadMessageNumber(group: group))")
                            .font(AppTheme.fonts.textXSmall.font)
                            .foregroundColor(AppTheme.colors.offWhite.color)
                            .frame(width: 24, height: 24, alignment: .center)
                            .background(AppTheme.colors.secondary.color)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
}

// Implement p2p & group chat

extension ServerMainView {
    
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
                    } else {
                        requestKeyInGroup(byGroupId: publication.groupID, publication: publication)
                    }
                } else {
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

struct ServerMainView_Previews: PreviewProvider {
    static var previews: some View {
        ServerMainView(isShowingServerDetailView: .constant(true))
    }
}
