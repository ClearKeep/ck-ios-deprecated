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
            ZStack(alignment: .top) {
                Color(.white).opacity(0.2).edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            viewRouter.current = .tabview
                        }){
                            Image(systemName: "chevron.backward")
                        }
                        TextFieldContent(key: "username", value: $keySearch)
                        Button(action: {
                            viewModel.searchUser(self.keySearch)
                        }){
                            Image("ic_search").resizable().frame(width: 25, height: 25)
                        }
                    }
                    Group {
                        List(viewModel.users){ user in
                            NavigationLink(destination:  MessageChatView(clientId: user.id, userName: user.userName))
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
                }
            }
            .padding()
            .navigationBarTitle(Text(""), displayMode: .inline)
            
        }
        
    }
}

struct SearchPeopleView_Previews: PreviewProvider {
    static var previews: some View {
        SearchPeopleView()
    }
}
