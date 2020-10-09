//
//  HomeView.swift
//  ClearKeep
//
//  Created by LuongTiem on 10/7/20.
//

import SwiftUI
import SwiftProtobuf
import NIO
import GRPC
import SignalProtocol

struct HomeView: View {
    
    
    private func testSignal() {
        
        
        


//
//        Backend.shared.authenticated(signAddresss: signalAddress, bundleStore: bobStore) { (result, error) in
//            
//            print(result)
//        }
        
        
        
     
        
        
        
      
    }
    
    
    var body: some View {
        Text("ClearKeep").onAppear(perform: {
            self.testSignal()
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
