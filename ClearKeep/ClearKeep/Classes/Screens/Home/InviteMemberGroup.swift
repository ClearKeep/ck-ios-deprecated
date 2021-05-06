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
    @Binding var isPresentModel: Bool
    
    @State var users : [People] = []
    @State var hudVisible : Bool = false

    var body: some View {
        VStack(alignment: .leading , spacing: 0){
            Spacer()
                .grandientBackground()
                .frame(width: UIScreen.main.bounds.width, height: 60)
            
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        isPresentModel = false
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("ic_close")
                            .frame(width: 24, height: 24)
                            .foregroundColor(AppTheme.colors.gray1.color)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: CreateRoomView(listMembers: self.selectedRows.map{$0}).environmentObject(RealmGroups())) {
                        Text("Next")
                            .font(AppTheme.fonts.linkMedium.font)
                            .foregroundColor(AppTheme.colors.primary.color)
                    }
                    .opacity(self.selectedRows.isEmpty ? 0.3 : 1.0)
                    .disabled(self.selectedRows.isEmpty)
                }
                .padding(.top, 29)
                
                Text("New Message")
                    .font(AppTheme.fonts.linkLarge.font)
                    .foregroundColor(AppTheme.colors.black.color)
                    .padding(.top, 23)
                
                SearchBar(text: $searchText) { (changed) in
                    if changed {
                    } else {
                        self.searchUser(searchText)
                    }
                }
                
                listSelectedUserView()
                
                Text("User in this Channel")
                    .font(AppTheme.fonts.textMedium.font)
                    .foregroundColor(AppTheme.colors.gray2.color)
                    .padding([.top , .bottom] , 16)
                
                Group {
                    ScrollView(.vertical, showsIndicators: false, content: {
                        VStack(alignment:.leading , spacing: 16) {
                            ForEach(self.users , id: \.id) { user in
                                MultipleSelectionRow(people: user, selectedItems: $selectedRows)
                            }
                        }
                    })
                }
                
            }.padding([.trailing , .leading , .bottom] , 16)
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
        .onAppear(){
            self.getListUser()
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
        Backend.shared.getListUser { (result, error) in
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
        Backend.shared.searchUser(keySearch.trimmingCharacters(in: .whitespaces).lowercased()) { (result, error) in
            DispatchQueue.main.async {
                self.hudVisible = false
                if let result = result {
                    self.users = result.lstUser.map {People(id: $0.id, userName: $0.displayName, userStatus: .Online)}.sorted {$0.userName.lowercased() < $1.userName.lowercased()}
                }
            }
        }
    }
}
