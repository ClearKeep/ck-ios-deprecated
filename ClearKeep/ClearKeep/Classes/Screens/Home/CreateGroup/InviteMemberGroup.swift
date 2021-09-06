//
//  InviteMemberGroup.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

struct InviteMemberGroup: View {
    
    @ObservedObject var viewModel = InviteMemberViewModel()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var selectedRows = Set<People>()
    @State private var searchText: String = ""
    
    @State var users : [People] = []
    @State var hudVisible : Bool = false
    
    @State var addUserFromOtherServer: Bool = false
    @State var userURL: String = ""
    
    @State private var activeCreateRoomView = false
    
    @State private var user: People = People(id: "", userName: "", userStatus: .Online)
    
    var body: some View {
        VStack(alignment: .leading) {
            SearchBar(text: $searchText) { (changed) in
                if changed {
                } else {
                    self.searchUser(searchText)
                }
            }
            
            listSelectedUserView()
            
            HStack(spacing: 8) {
                Button(action: {
                    addUserFromOtherServer.toggle()
                }) {
                    Image(addUserFromOtherServer ? "Checkbox" : "Ellipse20")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                
                Text("Add User From Other Server")
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.black.color)
                
                Spacer()
            }
            .padding(.top, 10)
            
            if addUserFromOtherServer {
                Group {
                    WrappedTextFieldWithLeftIcon("Paste your friend's link", text: $userURL, errorMessage: .constant(""), isFocused: .constant(false))
                    
                    NavigationLink(destination: CreateRoomView(listMembers: self.selectedRows.map{$0}),
                                   isActive: .constant(activeCreateRoomView),
                                   label: { EmptyView() })
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        RoundedGradientButton("Add", fixedWidth: 120, disable: .constant(userURL.isEmpty), action: {
                            getUserInfo()
                        })
                        Spacer()
                    }
                }
            } else {
                Group {
                    ScrollView(.vertical, showsIndicators: false, content: {
                        VStack(alignment:.leading , spacing: 16) {
                            ForEach(self.users , id: \.id) { user in
                                MultipleSelectionRow(people: user, selectedItems: $selectedRows)
                            }
                        }
                    })
                    
                    NavigationLink(destination: CreateRoomView(listMembers: self.selectedRows.map{$0}),
                                   isActive: .constant(activeCreateRoomView),
                                   label: { EmptyView() })
                    
                    HStack {
                        Spacer()
                        RoundedGradientButton("Next", fixedWidth: 120, disable: .constant(self.selectedRows.count == 0), action: {
                            activeCreateRoomView = true
                        })
                        Spacer()
                    }
                }
            }
        }
        .padding([.trailing , .leading , .bottom] , 16)
        .applyNavigationBarPlainStyleDark(title: "Create group", leftBarItems: {
            Image("Chev-left")
                .frame(width: 40, height: 40)
                .foregroundColor(AppTheme.colors.black.color)
                .fixedSize()
                .scaledToFit()
                .onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
                }
        }, rightBarItems: {
            Spacer()
        })
        .onAppear(){
            //self.getListUser()
        }
        .hud(.waiting(.circular, "Waiting..."), show: self.hudVisible)
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

extension InviteMemberGroup {
    // View
    private func listSelectedUserView() -> some View {
        FlexibleView(data: self.selectedRows.map{$0}, spacing: 8, alignment: .leading) { user in
            VStack {
                Spacer()
                
                HStack {
                    Text(user.userName)
                        .font(AppTheme.fonts.textXSmall.font)
                        .foregroundColor(AppTheme.colors.black.color)
                        .padding(.leading, 8)
                    
                    Button {
                        selectedRows.remove(user)
                    } label: {
                        Image("ic_close")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 15, height: 15)
                            .foregroundColor(AppTheme.colors.gray1.color)
                            .padding(.trailing, 11)
                    }
                }
                
                Spacer()
            }
            .frame(height: 30)
            .background(AppTheme.colors.gray5.color)
            .cornerRadius(16)
            .clipped()
        }
    }
    
    func getListUser(){
        self.hudVisible = true
        Multiserver.instance.currentServer.getListUser { (result, error) in
            DispatchQueue.main.async {
                self.hudVisible = false
                if let result = result {
                    self.users = result.lstUser.map {People(id: $0.id, userName: $0.displayName, userStatus: .Online)}.sorted {$0.userName.lowercased() < $1.userName.lowercased()}
                }
            }
        }
    }
    
    func searchUser(_ keySearch: String){
        self.hudVisible = true
        Multiserver.instance.currentServer.searchUser(keySearch.trimmingCharacters(in: .whitespaces).lowercased()) { (result, error) in
            DispatchQueue.main.async {
                self.hudVisible = false
                if let result = result {
                    self.users = result.lstUser.map {People(id: $0.id, userName: $0.displayName, userStatus: .Online)}.sorted {$0.userName.lowercased() < $1.userName.lowercased()}
                }
            }
        }
    }
    
    func getUserInfo() {
        //Ex: 54.235.68.160:25000:69b14823-9612-4fa4-9023-f11351e921e2
        let url = "54.235.68.160:25000:69b14823-9612-4fa4-9023-f11351e921e2".trimmingCharacters(in: .whitespacesAndNewlines)
        guard let workspaceDomain = url.components(separatedBy: ":").first,
              let userId = url.components(separatedBy: ":").last else {
            return
        }
        
        self.hudVisible = true
        Multiserver.instance.currentServer.getUserInfo(userId: userId, workspaceDomain: workspaceDomain) { (result, error) in
            DispatchQueue.main.async {
                self.hudVisible = false
                guard let result = result else {
                    return
                    
                }
                
                if result.id.isEmpty && result.displayName.isEmpty {return}
                user = People(id: result.id, userName: result.displayName, userStatus: .Online)
                if !self.selectedRows.contains(user) {
                    self.selectedRows.insert(user)
                }
                activeCreateRoomView = true
            }
        }
    }
    
}
