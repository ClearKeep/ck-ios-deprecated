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
    
    var body: some View {
        NavigationView {
            List(viewModel.users){ user in
                
                NavigationLink(destination:  MessageChatView(clientId: user.id, groupID: 0, userName: user.userName)
                                .environmentObject(groupRealms)
                                .environmentObject(messsagesRealms))
                {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                    VStack(alignment: .leading) {
                        Text(user.userName)
                        //                            Text(user.id)
                        //                                .font(.subheadline)
                        //                                .foregroundColor(.gray)
                    }
                }
            }
            //            .sheet(isPresented: $presentingModal, content: {
            //                MessageChatView(clientId: userSelected!.id, groupID: 0, userName: userSelected!.userName)
            //                    .environmentObject(groupRealms)
            //                    .environmentObject(messsagesRealms)
            //            })
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(leading: Text("People"),
                                trailing: NavigationLink(destination: SearchPeopleView(), isActive: $isSearchMember, label: {
                                    Text("Search")
                                }))
            .onAppear(){
                viewModel.getUser()
            }
        }
        //        .onAppear(){
        //            viewModel.getUser()
        //        }
        
    }
}

struct PeopleView_Previews: PreviewProvider {
    
    static var previews: some View {
        PeopleView()
    }
}
