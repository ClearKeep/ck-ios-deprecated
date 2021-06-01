//
//  CreateRoomView.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

struct CreateRoomView: View {
    
    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewRouter: ViewRouter
    
    // MARK: - ObservedObject
    @ObservedObject var viewModel: CreateRoomViewModel = CreateRoomViewModel()
    
    // MARK: - State
    @State private var groupName: String = ""
    @State private var groupId: Int64 = 0
    @State private var hudVisible = false
    @State private var isActive = false
    
    
    init(listMembers: [People]) {
        self.viewModel.setup(listMembers: listMembers)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: MessagerGroupView(groupName: groupName, groupId: groupId, isFromCreateGroup: true), isActive: .constant(groupId != 0), label: { EmptyView() })
            Text("Group Name")
                .font(AppTheme.fonts.textSmall.font)
                .foregroundColor(AppTheme.colors.gray1.color)
                .padding(.top, 23)
                .padding(.bottom, 5)
            
            HStack {
                TextField("Name this group", text: $groupName)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .font(AppTheme.fonts.textSmall.font)
                    .padding(4)
                    .frame(height: 52)
                
            }
            .padding(.horizontal)
            .background(AppTheme.colors.gray5.color)
            .cornerRadius(16)
            .clipped()
            
            Text("User in this Group")
                .font(AppTheme.fonts.textMedium.font)
                .foregroundColor(AppTheme.colors.gray2.color)
                .padding([.top , .bottom] , 16)
            
            Group {
                ScrollView(.vertical, showsIndicators: false, content: {
                    VStack(alignment:.leading , spacing: 16) {
                        ForEach(viewModel.listMembers , id: \.id) { user in
                            ContactView(people: user)
                        }
                    }
                })
            }
        }
        .padding([.trailing , .leading , .bottom] , 16)
        .applyNavigationBarGradidentStyle(title: "New Group Message", leftBarItems: {
            Button {
                self.presentationMode.wrappedValue.dismiss()
            } label: {
                Image("arrow-left")
                    .frame(width: 24, height: 24)
                    .foregroundColor(AppTheme.colors.gray1.color)
            }
        }, rightBarItems: {
            Button {
                hudVisible = true
                viewModel.createRoom(groupName: groupName, completion: { groupId in
                    hudVisible = false
                    self.groupId = groupId
                })
            } label: {
                Text("Create")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.primary.color)
            }
            .opacity(self.groupName.isEmpty ? 0.3 : 1.0)
            .disabled(self.groupName.isEmpty)
        })
        .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}
