//
//  PeopleView.swift
//  ClearKeep
//
//  Created by Seoul on 11/16/20.
//

import SwiftUI

struct PeopleView: View {
    
    @ObservedObject var viewModel = PeopleViewModel()
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var messsagesRealms : RealmMessages
    @State var presentingModal = false
    @State var userSelected: People?
    @State var isSearchMember : Bool = false
    
    @State var users: [People] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                customeNavigationBarView()
                
                Group {
                    if users.isEmpty {
                        Spacer()
                        Text("No contact found")
                            .font(.title)
                            .foregroundColor(.gray)
                            .lineLimit(nil)
                            .frame(width: 300, alignment: .center)
                            .multilineTextAlignment(.center)
                        Spacer()
                    } else {
                        List(users){ user in
                            
                            NavigationLink(destination:  MessageChatView(clientId: user.id, groupID: 0, userName: user.userName)
                                            .environmentObject(groupRealms)
                                            .environmentObject(messsagesRealms))
                            {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                VStack(alignment: .leading) {
                                    Text(user.userName)
                                }
                            }
                        }
                    }
                }
            }
//            .navigationBarTitle(Text(""), displayMode: .inline)
//            .navigationBarItems(leading: Text("People"),
//                                trailing: NavigationLink(destination: SearchPeopleView(), isActive: $isSearchMember, label: {
//                                    Text("Search")
//                                }))
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarHidden(true)
            .onAppear(){
                self.getUser()
            }
        }
    }
}

extension PeopleView {

    func customeNavigationBarView() -> some View {
        VStack {
            Spacer()
            HStack {
                Text("People")
                    .foregroundColor(AppTheme.colors.offWhite.color)
                    .font(AppTheme.fonts.textLarge.font)
                    .fontWeight(.medium)
                    .padding(.leading, 20)
                
                Spacer()
                
                NavigationLink(destination: SearchPeopleView(), isActive: $isSearchMember, label: {
                    Text("Search")
                })
            }
        }
        .padding()
        .applyNavigationBarStyle()
    }
}

extension PeopleView {
    func getUser(){
        Backend.shared.getListUser { (result, error) in
            if let result = result {
                self.users = result.lstUser.map{People(id: $0.id, userName: $0.displayName)}
            } else {
                print("getListUser Error: \(error?.localizedDescription ?? "")")
            }
        }
    }
}

struct PeopleView_Previews: PreviewProvider {
    
    static var previews: some View {
        PeopleView()
    }
}
