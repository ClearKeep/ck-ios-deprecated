//
//  InviteMemberGroup.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

struct InviteMemberGroup: View {
    
    @ObservedObject var viewModel = InviteMemberViewModel()
    
    var selectObserver : CreateRoomViewModel

    @State var selectedRows = Set<People>()
            
    var body: some View {
        
        List(viewModel.peoples, selection: $selectedRows){ item in
            MultipleSelectionRow(people: item, selectedItems: self.$selectedRows)
        }
        .onAppear(){
            self.viewModel.getListUser()
        }.onDisappear() {
            self.selectObserver.peoples = self.selectedRows.map{$0}
        }
    }
}
