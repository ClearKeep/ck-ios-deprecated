//
//  InviteMemberGroup.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

struct InviteMemberGroup: View {
    
    @ObservedObject var viewModel = InviteMemberViewModel()
        
    @State var selectedRows = Set<People>()
    
    @Binding var isPresentModel: Bool

            
    var body: some View {
        
        List(viewModel.peoples, selection: $selectedRows){ item in
            MultipleSelectionRow(people: item, selectedItems: self.$selectedRows)
        }
        .navigationBarTitle(Text("Add members"))
        .navigationBarItems(trailing: NavigationLink(
            destination: CreateRoomView(listMembers: self.selectedRows.map{$0})
        ) {
            Text("Next")
        })
        .hud(.waiting(.circular, "Waiting..."), show: self.viewModel.hudVisible)
        .onAppear(){
            self.viewModel.getListUser()
        }
    }
}
