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
            Group {
                if users.isEmpty {
                    Text("No contact found")
                        .font(.title)
                        .foregroundColor(.gray)
                        .lineLimit(nil)
                        .frame(width: 300, alignment: .center)
                        .multilineTextAlignment(.center)
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
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(leading: Text("People"),
                                trailing: NavigationLink(destination: SearchPeopleView(), isActive: $isSearchMember, label: {
                                    Text("Search")
                                }))
            .onAppear(){
                self.getUser()
            }
        }
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
