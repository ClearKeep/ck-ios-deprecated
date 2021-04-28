//
//  PeopleView.swift
//  ClearKeep
//
//  Created by Seoul on 11/16/20.
//

import SwiftUI

struct PeopleView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var messsagesRealms : RealmMessages
    
    @State private var searchText: String = ""
    @ObservedObject var viewModel = PeopleViewModel()
    
    @State var users: [People] = []
    
    @Binding var isPresentModel: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading , spacing: 0){
                Spacer()
                    .grandientBackground()
                    .frame(width: UIScreen.main.bounds.width, height: 60)
                
                VStack(alignment: .leading) {
                    Button {
                        isPresentModel = false
                        
                    } label: {
                        Image("ic_close")
                            .frame(width: 24, height: 24)
                            .foregroundColor(AppTheme.colors.gray1.color)
                    }
                    .padding(.top, 29)
                    
                    Text("New Message")
                        .font(AppTheme.fonts.linkLarge.font)
                        .foregroundColor(AppTheme.colors.black.color)
                        .padding(.top, 23)
                    
                    SearchBar(text: $searchText) { (changed) in
                        if changed {
                        } else {
                            viewModel.searchUser(searchText)
                        }
                    }
                    
                    Text("User in this Channel")
                        .font(AppTheme.fonts.textMedium.font)
                        .foregroundColor(AppTheme.colors.gray2.color)
                        .padding([.top , .bottom] , 16)
                    
                    Group {
                        ScrollView(.vertical, showsIndicators: false, content: {
                            VStack(alignment:.leading , spacing: 16) {
                                List(viewModel.users , id: \.id) { user in
                                    NavigationLink(destination:  MessageChatView(clientId: user.id, groupID: 0, userName: user.userName)
                                                    .environmentObject(groupRealms)
                                                    .environmentObject(messsagesRealms)){
                                        ContactView(people: user)
                                    }
                                }
                            }
                        })
                    }

                    
                }.padding([.trailing , .leading , .bottom] , 16)
                
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarHidden(true)
        }
        
        .navigationBarTitle(Text(""), displayMode: .inline)
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onAppear(){
            viewModel.getListUser()
        }
        .hud(.waiting(.circular, "Waiting..."), show: viewModel.hudVisible)
        .gesture(
            TapGesture()
                .onEnded { _ in
                    UIApplication.shared.endEditing()
                })
    }
}
