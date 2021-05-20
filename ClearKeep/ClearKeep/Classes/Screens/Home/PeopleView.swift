//
//  PeopleView.swift
//  ClearKeep
//
//  Created by Seoul on 11/16/20.
//

import SwiftUI

struct PeopleView: View {
    
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var messsagesRealms : RealmMessages
    
    @State private var searchText: String = ""
    @ObservedObject var viewModel = PeopleViewModel()
    
    @State private var peoples : [People] = []
    @State var hudVisible : Bool = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                SearchBar(text: $searchText) { (changed) in
                    if changed {
                    } else {
                        self.searchUser(searchText)
                    }
                }

                Text("User in this Channel")
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.gray2.color)
                    .padding([.top , .bottom] , 16)
                
                Group {
                    ScrollView(.vertical, showsIndicators: false, content: {
                        HStack {
                            VStack(alignment:.leading , spacing: 16) {
                                ForEach(self.peoples , id: \.id) { user in
                                    NavigationLink(destination: GroupChatView(userName: user.userName, clientId: user.id)){
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
            .padding([.trailing , .leading , .bottom] , 16)
            .applyNavigationBarGradidentStyle(title: "New Message", leftBarItems: {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("ic_close")
                        .frame(width: 24, height: 24)
                        .foregroundColor(AppTheme.colors.gray1.color)
                }
            }, rightBarItems: {
                Spacer()
            })
        }
        .onAppear(){
            self.getListUser()
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
        Backend.shared.getListUser { (result, error) in
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
        Backend.shared.searchUser(keySearch.trimmingCharacters(in: .whitespaces).lowercased()) { (result, error) in
            DispatchQueue.main.async {
                self.hudVisible = false
                if let result = result {
                    self.peoples = result.lstUser.map {People(id: $0.id, userName: $0.displayName, userStatus: .Online)}.sorted {$0.userName.lowercased() < $1.userName.lowercased()}
                }
            }
        }
    }
}
