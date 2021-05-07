//
//  CreateRoomView.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

struct CreateRoomView: View {
    
    @State var groupName: String = ""
    @State var userName: String = ""
    @State var isDisable = true
    @State private var showSelectMemberView = false
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var realmGroups : RealmGroups
    
    @State var hudVisible = false
    @State var isShowAlert = false
    @State private var titleAlert = ""
    @State private var messageAlert = ""
    @State private var createGroupSuccess = false
    
    private let listMembers : [People]
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(listMembers: [People]) {
        self.listMembers = listMembers
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Group Name")
                .font(AppTheme.fonts.textSmall.font)
                .foregroundColor(AppTheme.colors.gray1.color)
                .padding(.top, 23)
                .padding(.bottom, 5)
            
            HStack {
                TextField("Name this group", text: $groupName)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(AppTheme.fonts.textSmall.font)
                    .padding(4)
                    .frame(height: 52)
                
            }
            .padding(.horizontal)
            .background(AppTheme.colors.gray5.color)
            .cornerRadius(16)
            .clipped()
            
            Text("User in this Group")
                .font(AppTheme.fonts.textMedium.font)
                .foregroundColor(AppTheme.colors.gray2.color)
                .padding([.top , .bottom] , 16)
            
            Group {
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(alignment:.leading , spacing: 16) {
                        ForEach(listMembers , id: \.id) { user in
                            ContactView(people: user)
                        }
                    }
                })
            }
        }
        .padding([.trailing , .leading , .bottom] , 16)
        .applyNavigationBarStyle(title: "New Group Message", leftBarItems: {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image("arrow-left")
                    .frame(width: 24, height: 24)
                    .foregroundColor(AppTheme.colors.gray1.color)
            }
        }, rightBarItems: {
            Button {
                createRoom()
            } label: {
                Text("Create")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.primary.color)
            }
            .opacity(self.groupName.isEmpty ? 0.3 : 1.0)
            .disabled(self.groupName.isEmpty)
        })
        .alert(isPresented: self.$isShowAlert, content: {
            Alert(title: Text(self.titleAlert),
                  message: Text(self.messageAlert),
                  dismissButton: .default(Text("OK"), action: {
                    if self.createGroupSuccess {
                        //self.viewRouter.current = .tabview
                        self.viewRouter.current = .recentCreatedGroupChat
                    }
                  }))
        })
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

extension CreateRoomView {
    
    private func createRoom(){
        
        if groupName.trimmingCharacters(in: .whitespaces).isEmpty {
            self.isShowAlert = true
            self.titleAlert = "Create Room Error"
            self.messageAlert = "Group name can't be empty"
            return
        }
        
        var lstClientID = self.listMembers.map{ GroupMember(id: $0.id, username: $0.userName)}
        
        if lstClientID.isEmpty {
            self.isShowAlert = true
            self.titleAlert = "Create Room Error"
            self.messageAlert = "Group need at least 2 member"
            return
        }
        
        if let account = CKSignalCoordinate.shared.myAccount {
            
            let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserID) ?? "") as String
            lstClientID.append(GroupMember(id: account.username, username: userNameLogin))
            var req = Group_CreateGroupRequest()
            req.groupName = self.groupName
            req.groupType = "group"
            req.createdByClientID = account.username
            req.lstClientID = lstClientID.map{$0.id}
            
            self.hudVisible = true
            
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
                                               lastMessage: Data(),
                                               idLastMessage: result.lastMessage.id,
                                               timeSyncMessage: 0)
                        self.realmGroups.add(group: group)
                        self.viewRouter.recentCreatedGroupModel = group
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
