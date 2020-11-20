//
//  HistoryChatView.swift
//  ClearKeep
//
//  Created by Seoul on 11/18/20.
//

import SwiftUI

struct HistoryChatView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var viewModel = HistoryChatViewModel()
    
    var body: some View {
        
        NavigationView {
            List(viewModel.groups){ group in
                Image(systemName: "car.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text(group.groupName)
                    Text(group.createdByClientID)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(leading: Text("Chat"))
        }.onAppear(){
            self.viewModel.getJoinedGroup()
        }
    }
}

struct HistoryChatView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryChatView()
    }
}
