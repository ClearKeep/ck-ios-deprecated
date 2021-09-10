//
//  PeopleView.swift
//  ClearKeep
//
//  Created by Seoul on 11/16/20.
//

import SwiftUI

struct PeopleView: View {
    
    @State private var searchText: String = ""
    @ObservedObject var viewModel = PeopleViewModel()
    
    @State private var peoples : [People] = []
    @State var hudVisible : Bool = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var addUserFromOtherServer: Bool = false
    @State var userURL: String = ""
    
    @State private var user: People = People(id: "", userName: "", userStatus: .Online)
    
    @State private var activeOtherUser = false

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                SearchBar(text: $searchText) { (changed) in
                    if changed {
                    } else {
                        self.searchUser(searchText)
                    }
                }

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
                        
                        NavigationLink(destination: MessagerView(clientId: user.id, groupId: 0, userName: user.userName, workspace_domain: user.workspace_domain, isFromPeopleList: true),
                                       isActive: .constant(activeOtherUser),
                                       label: { EmptyView() })
                        
                        Spacer()
                        HStack {
                            Spacer()
                            RoundedGradientButton("Next", fixedWidth: 120, disable: .constant(userURL.isEmpty), action: {
                                getUserInfo()
                            })
                            Spacer()
                        }
                    }
                } else {
                    Group {
                        ScrollView(.vertical, showsIndicators: false, content: {
                            HStack {
                                VStack(alignment:.leading , spacing: 16) {
                                    ForEach(self.peoples , id: \.id) { user in
                                        NavigationLink(destination:  MessagerView(clientId: user.id, groupId: 0, userName: user.userName, workspace_domain: user.workspace_domain, isFromPeopleList: true)) {
                                            ContactView(people: user)
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                            .frame(width: geometry.size.width - 32)
                        })
                    }
                }
                
            }
            .padding([.trailing , .leading , .bottom] , 16)
            .applyNavigationBarPlainStyleDark(title: "Create direct message", leftBarItems: {
                ButtonBack(action: {
                    presentationMode.wrappedValue.dismiss()
                })
            }, rightBarItems: {
                Spacer()
            })

        }
        .onAppear(){
            //self.getListUser()
        }
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

extension PeopleView {
    func getListUser(){
        self.hudVisible = true
        Multiserver.instance.currentServer.getListUser { (result, error) in
            DispatchQueue.main.async {
                self.hudVisible = false
                if let result = result {
                    self.peoples = result.lstUser.map {People(id: $0.id, userName: $0.displayName, userStatus: .Online)}.sorted {$0.userName.lowercased() < $1.userName.lowercased()}
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
                    self.peoples = result.lstUser.map {People(id: $0.id, userName: $0.displayName, userStatus: .Online)}.sorted {$0.userName.lowercased() < $1.userName.lowercased()}
                }
            }
        }
    }
    
    private func getInfo(from url: String) -> (String, String) {
        if !url.contains(":") {
            return (url, "")
        }
        
        let workspaceDomain = url.components(separatedBy: ":").first ?? ""
        let userId = url.components(separatedBy: ":").last ?? ""
        return (workspaceDomain, userId)
    }
    
    func getUserInfo() {
        //Ex: 54.235.68.160:25000:69b14823-9612-4fa4-9023-f11351e921e2
        let url = userURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let (workspaceDomain, userId) = getInfo(from: url)
        
        self.hudVisible = true
        Multiserver.instance.currentServer.getUserInfo(userId: userId, workspaceDomain: workspaceDomain) { result in
            self.hudVisible = false
            
            switch result {
            case .success(let response):
                if response.id.isEmpty && response.displayName.isEmpty { return }
                user = People(id: response.id, userName: response.displayName, userStatus: .Online)
                activeOtherUser = true
            case .failure:
                return
            }
        }
    }
}
