//
//  CreateRoomView.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

struct CreateRoomView: View {
    
    @ObservedObject var viewModel = InviteMemberViewModel()
    
    @State var groupName: String = ""
    @State var userName: String = ""
    @State var isDisable = true
    @State private var showSelectMemberView = false
    
    @ObservedObject var selectObserver = CreateRoomViewModel()
    
    @EnvironmentObject var realmGroups : RealmGroups
    
    @Binding var isPresentModel: Bool
    
    @State var hudVisible = false
    @State var isShowAlert = false
    @State private var titleAlert = ""
    @State private var messageAlert = ""
    @State private var createGroupSuccess = false

    
    
    var body: some View {
        VStack {
            TitleLabel("Create Room Chat")
            TextFieldContent(key: "Group Name", value: $groupName)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            VStack {
                HStack() {
                    Text("Members:")
                    Text(self.getAllMember()).lineLimit(1)
                }
                NavigationLink(destination: InviteMemberGroup(selectObserver: selectObserver)) {
                    Text("Add members")
                }
                .padding()
            }
            Button(action: createRoom){
                ButtonContent("Create")
            }
        }
        .alert(isPresented: self.$isShowAlert, content: {
            Alert(title: Text(self.titleAlert),
                  message: Text(self.messageAlert),
                  dismissButton: .default(Text("OK"), action: {
                    if self.createGroupSuccess {
                        isPresentModel = false
                    }
                  }))
        })
        .padding()
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
    }
}

extension CreateRoomView {
    
    private func handleSelected(){
        
    }
    
    private func getAllMember() -> String{
//        let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserID) ?? "") as String
        var name = ""
        self.selectObserver.peoples.forEach { (people) in
            name += "\(people.userName),"
        }
        return String(name.dropLast())
    }
    
    private func createRoom(){
        
        if groupName.trimmingCharacters(in: .whitespaces).isEmpty {
            self.isShowAlert = true
            self.titleAlert = "Create Room Error"
            self.messageAlert = "Group name can't be empty"
            return
        }
        
        var lstClientID = self.selectObserver.peoples.map{ GroupMember(id: $0.id, username: $0.userName)}
        
        if lstClientID.isEmpty {
            self.isShowAlert = true
            self.titleAlert = "Create Room Error"
            self.messageAlert = "Group need at least 2 member"
            return
        }
        
        self.hudVisible = true
        
        if let account = CKSignalCoordinate.shared.myAccount {
            let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserID) ?? "") as String
            lstClientID.append(GroupMember(id: account.username, username: userNameLogin))
            var req = Group_CreateGroupRequest()
            req.groupName = self.groupName
            req.groupType = "group"
            req.createdByClientID = account.username
            req.lstClientID = lstClientID.map{$0.id}
            
            Backend.shared.createRoom(req) { (result , error)  in
                self.hudVisible = false
                if let result = result {
                    DispatchQueue.main.async {
                        let group = GroupModel(groupID: result.groupID,
                                               groupName: result.groupName,
                                               groupToken: result.groupRtcToken,
                                               groupAvatar: result.groupAvatar,
                                               groupType: result.groupType,
                                               createdByClientID: result.createdByClientID,
                                               createdAt: result.createdAt,
                                               updatedByClientID: result.updatedByClientID,
                                               lstClientID: lstClientID,
                                               updatedAt: result.updatedAt,
                                               lastMessageAt: result.lastMessageAt,
                                               lastMessage: Data(), idLastMessage: result.lastMessage.id)
                        self.realmGroups.add(group: group)
                    }
                    self.createGroupSuccess = true
                    self.isShowAlert = true
                    self.titleAlert = "Create Room Successfully"
                    self.messageAlert = ""
                }
            }
        }
    }
    
}
