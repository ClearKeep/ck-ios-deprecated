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

    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading , spacing: 0){
                Spacer()
                    .grandientBackground()
                    .frame(width: UIScreen.main.bounds.width, height: 60)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
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

                    FlexibleView(data: self.selectedRows.map{$0}, spacing: 8, alignment: .leading) { user in
                        HStack {
                            Text(user.userName)
                                .font(AppTheme.fonts.textSmall.font)
                                .foregroundColor(AppTheme.colors.black.color)
                                .padding(8)
                            
                            Button {
                                selectedRows.remove(user)
                            } label: {
                                Image("ic_close")
                                    .frame(width: 9, height: 9)
                                    .foregroundColor(AppTheme.colors.gray1.color)
                                    .padding(.trailing, 11)
                            }
                        }
                        .background(AppTheme.colors.gray5.color)
                        .cornerRadius(16)
                        .clipped()

                    }
                    
                    
                    
                    Text("User in this Channel")
                        .font(AppTheme.fonts.textMedium.font)
                        .foregroundColor(AppTheme.colors.gray2.color)
                        .padding([.top , .bottom] , 16)
                    
                    Group {
                        ScrollView(.vertical, showsIndicators: false, content: {
                            VStack(alignment:.leading , spacing: 16) {
                                ForEach(viewModel.users , id: \.id) { user in
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
