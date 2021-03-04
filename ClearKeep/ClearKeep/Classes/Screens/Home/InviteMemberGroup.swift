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
        .navigationBarTitle(Text("Group members"))
        .navigationBarItems(trailing: NavigationLink(
            destination: CreateRoomView(listMembers: self.selectedRows.map{$0})
        ) {
            Text("Next")
        })
        .onAppear(){
            self.viewModel.getListUser()
        }
    }
}
