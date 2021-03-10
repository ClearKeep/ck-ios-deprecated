//
//  NotificationService.swift
//  ClearKeep
//
//  Created by Seoul on 12/3/20.
//


import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC

class NotificationService {
    
    fileprivate let clientSignal: Notification_NotifyClientProtocol
    
    init(_ clientSignal: Notification_NotifyClientProtocol) {
        self.clientSignal = clientSignal
    }
}

extension NotificationService {
        
    func listen(clientId: String, heard: @escaping ((Notification_NotifyObjectResponse) -> Void)) {
        let request: Notification_ListenRequest = .with {
            $0.clientID = clientId
            
        }
        DispatchQueue.global(qos: .background).async {
            do {
                let call = self.clientSignal.listen(request) { publication in
                    guard let data = try? publication.serializedData(), let response = try? Notification_NotifyObjectResponse(serializedData: data) else {
                        print("Error serializedData")
                        return
                    }
                    DispatchQueue.main.async {
                        heard(response)
                    }
                }
                let status = try call.status.wait()
                print("listen finished: \(status)")
            } catch {
                print("Error", error.localizedDescription)
            }
        }
    }
    
    func subscribe(clientId: String, completion: @escaping (() -> Void)) {
        print("subscribe notify to \(clientId)")
        let request: Notification_SubscribeRequest = .with {
            $0.clientID = clientId
        }
        clientSignal.subscribe(request).response.whenComplete { (result) in
            print(result, "subscribe notify complete")
            completion()
        }
    }
    
    func unsubscribe(clientId: String, completion: @escaping (() -> Void)) {
        print("unsubscribe notify to \(clientId)")
        var request = Notification_UnSubscribeRequest()
        request.clientID = clientId
        clientSignal.un_subscribe(request).response.whenComplete { (result) in
            print(result, "unsubscribe notify complete")
            completion()
        }
    }
}
