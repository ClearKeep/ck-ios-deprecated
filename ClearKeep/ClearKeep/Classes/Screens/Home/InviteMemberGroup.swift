//
//  InviteMemberGroup.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

struct InviteMemberGroup: View {
    
    @ObservedObject var viewModel = InviteMemberViewModel()
    @EnvironmentObject var viewRouter: ViewRouter
    @State var selectedRows = Set<People>()
    
    var body: some View {
        NavigationView {
            List(viewModel.peoples, selection: $selectedRows){ item in
                MultipleSelectionRow(people: item, selectedItems: self.$selectedRows)
            }
            .navigationBarTitle(Text("Add members"))
            .navigationBarItems(leading:
                                    Image("ic_back_navigation")
                                    .scaledToFit()
                                    .foregroundColor(Color.blue)
                                    .frame(width: 50, height: 50)
                                    .onTapGesture {
                                        self.viewRouter.current = .tabview
                                    }
                                ,trailing: NavigationLink(
                                    destination: CreateRoomView(listMembers: self.selectedRows.map{$0}).environmentObject(RealmGroups())
                                ) {
                                    Text("Next")
                                })
            .hud(.waiting(.circular, "Waiting..."), show: self.viewModel.hudVisible)
            .onAppear(){
                self.viewModel.getListUser()
            }
        }
    }
    
    
}
