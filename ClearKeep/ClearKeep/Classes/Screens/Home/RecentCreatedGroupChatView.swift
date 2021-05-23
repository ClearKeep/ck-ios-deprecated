//
//  RecentCreatedGroupChatView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/26/21.
//

import SwiftUI
import AVFoundation

struct RecentCreatedGroupChatView: View {
    
    @EnvironmentObject var groupRealms : RealmGroups
    @EnvironmentObject var messsagesRealms : RealmMessages
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var hudVisible = false
    @State var alertVisible = false
    @ObservedObject var viewModel: MessageChatViewModel = MessageChatViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                GroupChatView(groupName: viewRouter.recentCreatedGroupModel!.groupName, groupId: viewRouter.recentCreatedGroupModel!.groupID)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: HStack {
                
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20 , alignment: .leading)
                    .padding(.leading, 10)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        self.viewRouter.current = .home
                    }
                Text("").frame(width: 40, height: 40)
                                                
                NavigationLink(
                    destination: GroupChatDetailView(groupModel: self.viewRouter.recentCreatedGroupModel!),
                    label: {
                        Text(self.viewRouter.recentCreatedGroupModel!.groupName)
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                    }).frame(maxWidth: .infinity , alignment: .center)
                
                HStack {
                    Button(action: {
                        call(callType: .audio)
                    }, label: {
                        Image(systemName: "phone.fill")
                            .frame(width: 40, height: 40)
                    })
                    Button(action: {
                        call(callType: .video)
                    }, label: {
                        Image(systemName: "video.fill")
                            .frame(width: 40, height: 40)
                    })
                }
                .padding(.trailing, 10)
            }.frame(width: UIScreen.main.bounds.width, height: 50)
            )
        }
    }
}

extension RecentCreatedGroupChatView {
    func call(callType type: Constants.CallType) {
        AVCaptureDevice.authorizeVideo(completion: { (status) in
            AVCaptureDevice.authorizeAudio(completion: { (status) in
                if status == .alreadyAuthorized || status == .justAuthorized {
                    hudVisible = true
                    // CallManager call
                    viewModel.callGroup(groupId: self.viewRouter.recentCreatedGroupModel!.groupID, callType: type) {
                        hudVisible = false
                    }
                } else {
                    self.alertVisible = true
                }
            })
        })
    }
}

struct RecentCreatedGroupChatView_Previews: PreviewProvider {
    static var previews: some View {
        RecentCreatedGroupChatView()
    }
}
