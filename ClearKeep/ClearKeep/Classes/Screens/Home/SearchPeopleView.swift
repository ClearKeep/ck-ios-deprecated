//
//  SearchPeopleView.swift
//  ClearKeep
//
//  Created by Seoul on 11/18/20.
//

import SwiftUI

struct SearchPeopleView: View {
    
    @State var keySearch: String = ""
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var viewModel = SearchPeopleViewModel()
    
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextFieldContent(key: "username", value: $keySearch)
                    Button(action: {
                        viewModel.searchUser(self.keySearch)
                    }){
                        Image("ic_search").resizable().frame(width: 25, height: 25)
                    }
                }
                List(viewModel.users){ user in
                    NavigationLink(destination:  MessageChatView(clientId: user.id, groupID: 0, userName: user.userName)
                                    .environmentObject(RealmGroups()).environmentObject(RealmMessages()))
                    {
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text(user.userName)
                            Text(user.id)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Search User"), displayMode: .inline)
        }
    }
}

struct SearchPeopleView_Previews: PreviewProvider {
    static var previews: some View {
        SearchPeopleView()
    }
}
