//
//  CreateRoomView.swift
//  ClearKeep
//
//  Created by Seoul on 11/24/20.
//

import SwiftUI

struct CreateRoomView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var viewModel = InviteMemberViewModel()

    @State var groupName: String = ""
    @State var userName: String = ""
    @State var isDisable = true
    @State private var showSelectMemberView = false
    
    @ObservedObject var selectObserver = CreateRoomViewModel()

    
    var body: some View {
        VStack {
            TitleLabel("Create Room Chat")
            TextFieldContent(key: "Group Name", value: $groupName)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            VStack {
                HStack() {
                    Text("Members:")
                    Text(self.getAllMember()).lineLimit(1)
                }
                NavigationLink(destination: InviteMemberGroup(selectObserver: selectObserver)) {
                                    Text("Add members")
                                }
                .padding()
            }
            Button(action: createRoom){
                ButtonContent("CREATE")
            }
        }
        .padding()
    }
}

extension CreateRoomView {
    
    private func handleSelected(){
        
    }
    
    private func getAllMember() -> String{
        let userNameLogin = (UserDefaults.standard.string(forKey: Constants.keySaveUserNameLogin) ?? "") as String
        var name = "\(userNameLogin)"
        self.selectObserver.peoples.forEach { (people) in
            name += ",\(people.userName)"
        }
        return name
    }
    
    private func createRoom(){
        
        if let account = CKSignalCoordinate.shared.myAccount {
            var lstClientID = self.selectObserver.peoples.map{$0.id}
            lstClientID.append(account.username)
                
            var req = Group_CreateGroupRequest()
            req.groupName = self.groupName
            req.groupType = "group"
            req.createdByClientID = account.username
            req.lstClientID = lstClientID
            
            Backend.shared.createRoom(req) { (response) in
                DispatchQueue.main.async {
                    self.viewRouter.current = .history
                }
            }
        }
    }
    
}

struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomView()
    }
}
