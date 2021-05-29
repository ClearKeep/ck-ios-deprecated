//
//  ServerMainView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/22/21.
//

import SwiftUI

struct ServerMainView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ServerMainViewModel
    
    @State private var searchText: String = ""
    @State private var isGroupChatExpanded: Bool = true
    @State private var isDirectMessageExpanded: Bool = true
    @State private var isShowingPeopleView = false

    @Binding var messageData: MessagerBannerModifier.MessageData
    @Binding var isShowMessageBanner: Bool
    
    var body: some View {
            VStack (spacing: 20) {
                SearchBar(text: $searchText) { (changed) in
                    if changed {
                    } else {
                        //self.searchUser(searchText)
                    }
                }
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(spacing: 20) {
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
                        
                        ListGroupView(titleSection: "Group Chat", groups: viewModel.groups, createNewGroup: InviteMemberGroup(), detail: { group in
                            MessagerGroupView(groupName: group.groupName, groupId: group.groupID)
                        }, content: { group in
                            HStack {
                                Text(viewModel.getGroupName(group: group))
                                    .font(AppTheme.fonts.linkSmall.font)
                                    .foregroundColor(AppTheme.colors.gray1.color)
                            }
                        })
                        
                        ListGroupView(titleSection: "Dirrect Messages", groups: viewModel.peers, createNewGroup: PeopleView(), detail: { group in
                            MessagerView(clientId: viewModel.getClientIdFriend(listClientID: group.lstClientID.map{$0.id}), groupId: group.groupID, userName: viewModel.getPeerReceiveName(inGroup: group))
                        }, content: { group in
                            HStack {
                                ChannelUserAvatar(avatarSize: 24, statusSize: 8, text: viewModel.getPeerReceiveName(inGroup: group), font: AppTheme.fonts.linkSmall.font, image: nil, status: .none, gradientBackgroundType: .accent)
                                
                                Text(viewModel.getPeerReceiveName(inGroup: group))
                                    .font(AppTheme.fonts.linkSmall.font)
                                    .foregroundColor(AppTheme.colors.gray1.color)
                            }
                        })
                        
                        Spacer()
                    }
                })
        }
        .padding(.bottom, 20)
        .onTapGesture {
            self.hideKeyboard()
        }
        .onAppear(){
            self.viewModel.getJoinedGroup()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Notification), perform: { (obj) in
            self.didReceiveMessageGroup(userInfo: obj.userInfo)
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.ReceiveMessage), perform: { (obj) in
            if let userInfo = obj.userInfo,
               let message = userInfo["message"] as? MessageModel {
                if message.groupID == ChatService.shared.openedGroupId { return }
                if message.groupType == "peer" {
                    self.messageData = MessagerBannerModifier.MessageData(senderName: RealmManager.shared.getSenderName(fromClientId: message.fromClientID, groupId: message.groupID), message: String(data: message.message, encoding: .utf8) ?? "x")
                } else {
                    self.messageData = MessagerBannerModifier.MessageData(groupName: RealmManager.shared.getGroupName(by: message.groupID), senderName: RealmManager.shared.getSenderName(fromClientId: message.fromClientID, groupId: message.groupID), message: String(data: message.message, encoding: .utf8) ?? "x")
                }
                self.isShowMessageBanner = true
                self.viewModel.reloadData()
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.AppBecomeActive), perform: { (obj) in
            self.viewModel.getJoinedGroup()
        })
    }
}

fileprivate struct ListGroupView<CreateNewGroupView, Destination, Content>: View where CreateNewGroupView: View, Destination: View, Content: View {
    
    // MARK: - State
    @State private var isExpanded: Bool = true
    
    // MARK: - Variables
    var titleSection: String
    var groups: [GroupModel]
    var createNewGroup: CreateNewGroupView
    var detail: (GroupModel) -> Destination
    var content: (GroupModel) -> Content
    
    // MARK: - Content view
    var body: some View {
        VStack(spacing: 16) {
            SectionGroupView(titleSection: "\(titleSection) (\(groups.count))", destination: createNewGroup, isExpanded: $isExpanded)
            
            if isExpanded && !groups.isEmpty {
                ForEach(groups, id: \.groupID) { group in
                    NavigationLink(destination: detail(group), label: {
                        content(group)
                        Spacer()
                    })
                }
                .padding(.leading, 16)
            }
        }
    }
}

fileprivate struct SectionGroupView<Destination>: View where Destination: View {
    
    // MARK: - Variables
    var titleSection: String
    var destination: Destination
    
    // MARK: - Binding
    @Binding var isExpanded: Bool
    
    // MARK: - Content view
    var body: some View {
        HStack() {
            Text(titleSection)
                .font(AppTheme.fonts.linkMedium.font)
                .foregroundColor(AppTheme.colors.gray1.color)
            
            Button(action: {
                self.isExpanded.toggle()
            }, label: {
                Image(isExpanded ? "Chev-down" : "Chev-up")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 18, height: 18, alignment: .center)
                    .foregroundColor(AppTheme.colors.gray1.color)
                    .padding(.all, 6)
            })
            
            Spacer()
            
            NavigationLink(destination: destination) {
                Image("Plus")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                    .foregroundColor(AppTheme.colors.gray1.color)
            }
        }
    }
}

// Implement p2p & group chat

extension ServerMainView {
    
//    func getProfileInfo() {
//        let userLogin = Backend.shared.getUserLogin()
//        self.currentUserName = userLogin?.displayName ?? ""
//    }
    
//    func updateLastMessageInGroup(groupResponse: Group_GroupObjectResponse){
//        // break last message with time login
//        if let loginDate = UserDefaults.standard.value(forKey: Constants.User.loginDate) as? Date {
//            let updateAt = NSDate(timeIntervalSince1970: TimeInterval(groupResponse.lastMessage.createdAt/1000))
//            if loginDate.compare(updateAt as Date) == ComparisonResult.orderedDescending {
//                return
//            }
//        }
//
//        let lastMessageResponse = groupResponse.lastMessage
//        var messageResponse = Message_MessageObjectResponse()
//        messageResponse.id = lastMessageResponse.id
//        messageResponse.groupID = lastMessageResponse.groupID
//        messageResponse.groupType = lastMessageResponse.groupType
//        messageResponse.fromClientID = lastMessageResponse.fromClientID
//        messageResponse.clientID = lastMessageResponse.clientID
//        messageResponse.message = lastMessageResponse.message
//        messageResponse.createdAt = lastMessageResponse.createdAt
//        messageResponse.updatedAt = lastMessageResponse.updatedAt
//        messageResponse.unknownFields = lastMessageResponse.unknownFields
//
//        if groupResponse.groupType == "peer" {
//            if let ourEncryptionMng = self.ourEncryptionManager {
//                do {
//                    let decryptedData = try ourEncryptionMng.decryptFromAddress(groupResponse.lastMessage.message,
//                                                                                name: groupResponse.lastMessage.fromClientID)
//                    let lastMessage = groupResponse.lastMessage
//                    DispatchQueue.main.async {
//                        let message = MessageModel(id: lastMessage.id,
//                                                   groupID: lastMessage.groupID,
//                                                   groupType: lastMessage.groupType,
//                                                   fromClientID: lastMessage.fromClientID,
//                                                   clientID: lastMessage.clientID,
//                                                   message: decryptedData,
//                                                   createdAt: lastMessage.createdAt,
//                                                   updatedAt: lastMessage.updatedAt)
//                        self.messsagesRealms.add(message: message)
//                        self.groupRealms.updateLastMessage(groupID: groupResponse.groupID, lastMessage: decryptedData, lastMessageAt: groupResponse.lastMessageAt, idLastMessage: groupResponse.lastMessage.id)
//                        self.groupRealms.sort()
//                        self.reloadData()
//                    }
//                } catch {
//                    print("decrypt message error: ---- getJoinnedGroup")
//                }
//            }
//        } else {
//            self.decryptionMessage(publication: messageResponse)
//        }
//    }
    
    func didReceiveMessageGroup(userInfo: [AnyHashable : Any]?) {
        if let userInfo = userInfo,
           let publication = userInfo["publication"] as? Notification_NotifyObjectResponse {
            if publication.notifyType == "new-peer" ||  publication.notifyType == "new-group" {
                self.viewModel.getJoinedGroup()
            }
        }
    }
    
//    func decryptionMessage(publication: Message_MessageObjectResponse) {
//
//        //        requestKeyInGroup(byGroupId: groupModel.groupID, publication: publication)
//        if let ourEncryptionMng = self.ourEncryptionManager,
//           let connectionDb = self.connectionDb {
//            do {
//                var account: CKAccount?
//                connectionDb.read { (transaction) in
//                    account = CKAccount.allAccounts(withUsername: publication.fromClientID, transaction: transaction).first
//                }
//                if let senderAccount = account {
//                    if ourEncryptionMng.senderKeyExistsForUsername(publication.fromClientID, deviceId: senderAccount.deviceId, groupId: publication.groupID) {
//                        let decryptedData = try ourEncryptionMng.decryptFromGroup(publication.message,
//                                                                                  groupId: publication.groupID,
//                                                                                  name: publication.fromClientID)
//                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
//                        print("Message decryption: \(messageDecryption ?? "Empty error")")
//
//                        DispatchQueue.main.async {
//                            let post = MessageModel(id: publication.id,
//                                                    groupID: publication.groupID,
//                                                    groupType: publication.groupType,
//                                                    fromClientID: publication.fromClientID,
//                                                    clientID: publication.clientID,
//                                                    message: decryptedData,
//                                                    createdAt: publication.createdAt,
//                                                    updatedAt: publication.updatedAt)
//                            self.messsagesRealms.add(message: post)
//                            self.messageData = MessagerBannerModifier.MessageData(
//                                groupName: RealmManager.shared.getGroupName(by: publication.groupID),
//                                senderName: RealmManager.shared.getDisplayNameSenderMessage(fromClientId: publication.clientID, groupID: publication.groupID),
//                                userIcon: nil,
//                                message: messageDecryption ?? "")
//                            self.isShowMessageBanner = true
//                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: decryptedData, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
//                            self.groupRealms.sort()
//                            self.reloadData()
//                        }
//
//                        return
//                    } else {
//                        requestKeyInGroup(byGroupId: publication.groupID, publication: publication)
//                    }
//                } else {
//                    requestKeyInGroup(byGroupId: publication.groupID, publication: publication)
//                }
//            } catch {
//                Debug.DLog("Decryption message error: \(error)")
//                requestKeyInGroup(byGroupId: publication.groupID, publication: publication)
//            }
//        }
//    }
    
//    func registerWithGroup(_ groupId: Int64) {
//        if let group = self.groupRealms.filterGroup(groupId: groupId) {
//            if !group.isRegistered {
//                if let myAccount = CKSignalCoordinate.shared.myAccount , let ourAccountEncryptMng = self.ourEncryptionManager {
//                    let userName = myAccount.username
//                    let deviceID = Int32(Constants.encryptedDeviceId)
//                    let address = SignalAddress(name: userName, deviceId: deviceID)
//                    let groupSessionBuilder = SignalGroupSessionBuilder(context: ourAccountEncryptMng.signalContext)
//                    let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
//
//                    do {
//                        let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
//                        Backend.shared.authenticator.registerGroup(byGroupId: groupId,
//                                                                   clientId: userName,
//                                                                   deviceId: deviceID,
//                                                                   senderKeyData: signalSKDM.serializedData()) { (result, error) in
//                            print("Register group with result: \(result)")
//                            if result {
//                                self.groupRealms.registerGroup(groupId: groupId)
//                            }
//                        }
//
//                    } catch {
//                        print("Register group error: \(error)")
//
//                    }
//                }
//            }
//        }
//    }
    
//    func requestKeyInGroup(byGroupId groupId: Int64, publication: Message_MessageObjectResponse) {
//
//        if self.isForceProcessKeyInGroup {
//            Backend.shared.authenticator.requestKeyGroup(byClientId: publication.fromClientID,
//                                                         groupId: groupId) {(result, error, response) in
//                guard let groupResponse = response else {
//                    Debug.DLog("Request prekey \(groupId) fail")
//                    return
//                }
//                self.processSenderKey(byGroupId: groupResponse.groupID,
//                                      responseSenderKey: groupResponse.clientKey)
//
//                // decrypt message again
//                self.decryptionMessage(publication: publication)
//                self.isForceProcessKeyInGroup = false
//            }
//        }
//    }
    
//    private func processSenderKey(byGroupId groupId: Int64,
//                                  responseSenderKey: Signal_GroupClientKeyObject) {
//
//        let deviceID = Constants.decryptedDeviceId
//
//        if let ourAccountEncryptMng = self.ourEncryptionManager,
//           let connectionDb = self.connectionDb {
//            // save account infor
//            connectionDb.readWrite { (transaction) in
//                var account = CKAccount.allAccounts(withUsername: responseSenderKey.clientID, transaction: transaction).first
//                if account == nil {
//                    account = CKAccount(username: responseSenderKey.clientID, deviceId: Int32(deviceID), accountType: .none)
//                    account?.save(with: transaction)
//                }
//            }
//            do {
//                let addresss = SignalAddress(name: responseSenderKey.clientID,
//                                             deviceId: Int32(deviceID))
//                try ourAccountEncryptMng.consumeIncoming(toGroup: groupId,
//                                                         address: addresss,
//                                                         skdmDtata: responseSenderKey.clientKeyDistribution)
//            } catch {
//                print("processSenderKey error: \(error)")
//            }
//        }
//    }
    
    
//    func didReceiveMessagePeer(userInfo: [AnyHashable : Any]?) {
//        if let userInfo = userInfo,
//           let publication = userInfo["publication"] as? Message_MessageObjectResponse{
//
//            //            Backend.shared.authenticator
//            //                .requestKey(byClientId: publication.fromClientID) {(result, error, response) in
//            //                    if let response = response {
//            if let ourEncryptionMng = self.ourEncryptionManager {
//                do {
//
//                    let message = self.messsagesRealms.all.filter{$0.id == publication.id}
//
//                    if message.isEmpty {
//                        let decryptedData = try ourEncryptionMng.decryptFromAddress(publication.message,
//                                                                                    name: publication.fromClientID)
//                        let messageDecryption = String(data: decryptedData, encoding: .utf8)
//                        print("Message decryption peer: \(messageDecryption ?? "Empty error")")
//                        let post = MessageModel(id: publication.id,
//                                                groupID: publication.groupID,
//                                                groupType: publication.groupType,
//                                                fromClientID: publication.fromClientID,
//                                                clientID: publication.clientID,
//                                                message: decryptedData,
//                                                createdAt: publication.createdAt,
//                                                updatedAt: publication.updatedAt)
//                        DispatchQueue.main.async {
//                            self.messageData = MessagerBannerModifier.MessageData(senderName: RealmManager.shared.getDisplayNameSenderMessage(fromClientId: publication.clientID, groupID: publication.groupID), userIcon: nil, message: messageDecryption ?? "")
//                            self.isShowMessageBanner = true
//                            self.messsagesRealms.add(message: post)
//                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: decryptedData, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
//                            self.groupRealms.sort()
//                            self.reloadData()
//
//                            print("message decypt realm: ----- \(viewModel.getMessage(data: self.groupRealms.all[0].lastMessage))")
//
//
//                        }
//                    } else {
//                        DispatchQueue.main.async {
//                            self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: message[0].message, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
//                            self.groupRealms.sort()
//                            self.reloadData()
//                        }
//                    }
//
//                } catch {
//
//                    DispatchQueue.main.async {
//                        let messageError = "unable to decrypt this message".data(using: .utf8) ?? Data()
//
//                        let post = MessageModel(id: publication.id,
//                                                groupID: publication.groupID,
//                                                groupType: publication.groupType,
//                                                fromClientID: publication.fromClientID,
//                                                clientID: publication.clientID,
//                                                message: messageError,
//                                                createdAt: publication.createdAt,
//                                                updatedAt: publication.updatedAt)
//                        self.messsagesRealms.add(message: post)
//                        self.groupRealms.updateLastMessage(groupID: publication.groupID, lastMessage: messageError, lastMessageAt: publication.createdAt, idLastMessage: publication.id)
//                        self.groupRealms.sort()
//                        self.reloadData()
//                    }
//                    Debug.DLog("Decryption message error: \(error)")
//                }
//            }
//        }
//    }
}


struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)

    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

extension UIViewController {
    func present<Content: View>(style: UIModalPresentationStyle = .automatic, @ViewBuilder builder: () -> Content) {
        let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
        toPresent.modalPresentationStyle = style
        toPresent.rootView = AnyView(
            builder()
                .environment(\.viewController, toPresent)
        )
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "dismissModal"), object: nil, queue: nil) { [weak toPresent] _ in
            toPresent?.dismiss(animated: true, completion: nil)
        }
        self.present(toPresent, animated: true, completion: nil)
    }
}
