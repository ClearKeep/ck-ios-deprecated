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
                GroupMessageChatView(groupModel: self.viewRouter.recentCreatedGroupModel!).environmentObject(self.groupRealms).environmentObject(self.messsagesRealms)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(leading: HStack {
                HStack {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18, alignment: .leading)
                        .foregroundColor(.blue)
                }
                .onTapGesture {
                    self.viewRouter.current = .tabview
                }
                
                NavigationLink(
                    destination: GroupChatDetailView(groupModel: self.viewRouter.recentCreatedGroupModel!),
                    label: {
                        Text(self.viewRouter.recentCreatedGroupModel!.groupName)
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                    })
            },
            trailing: HStack{
                Button(action: {
                    call(callType: .audio)
                }, label: {
                    Image(systemName: "phone.fill")
                        .frame(width: 50, height: 50, alignment: .trailing)
                })
                Button(action: {
                    call(callType: .video)
                }, label: {
                    Image(systemName: "video.fill")
                        .frame(width: 50, height: 50, alignment: .trailing)
                })
            })
            
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
                    viewModel.callGroup(group: self.viewRouter.recentCreatedGroupModel!, callType: type) {
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
