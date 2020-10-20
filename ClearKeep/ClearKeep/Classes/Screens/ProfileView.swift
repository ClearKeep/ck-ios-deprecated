//
//  ProfileView.swift
//  ClearKeep
//
//  Created by LuongTiem on 10/15/20.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @State private var showActionSheet = false

    var body: some View {
        VStack {
            Button(action: logout) {
                ButtonContent("LOGOUT")
                    .padding()
            }
            Button(action: delete) {
                ButtonContent("DELETE")
                .padding()
            }
        }.actionSheet(isPresented: $showActionSheet) {
            self.confirmationSheet
        }
    }

    private func logout() {
        
    }
    
    private var confirmationSheet: ActionSheet {
        ActionSheet(
            title: Text("Delete Account"),
            message: Text("Are you sure?"),
            buttons: [
                .cancel {},
                .destructive(Text("Delete")) {
                    self.delete()
                }
            ]
        )
    }

    private func confirmDelete() {
        showActionSheet = true
    }

    private func delete() {
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
