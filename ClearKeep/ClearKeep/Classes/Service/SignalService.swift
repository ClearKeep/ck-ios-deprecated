
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC


class SignalService {
    
    fileprivate let clientSignal: Message_MessageClientProtocol
    
    init(_ clientSignal: Message_MessageClientProtocol) {
        self.clientSignal = clientSignal
    }
}

extension SignalService {
        
    func listen(clientId: String, heard: @escaping ((String, Message_MessageObjectResponse) -> Void)) {
        let request: Message_ListenRequest = .with {
            $0.clientID = clientId
        }
        DispatchQueue.global(qos: .background).async {
            do {
                let call = self.clientSignal.listen(request) { publication in
                    guard let data = try? publication.serializedData(), let response = try? Message_MessageObjectResponse(serializedData: data) else {
                        print("Error serializedData")
                        return
                    }
                    DispatchQueue.main.async {
                        heard(publication.fromClientID, response)
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
        print("subscribe to \(clientId)")
        let request: Message_SubscribeRequest = .with {
            $0.clientID = clientId
        }
        clientSignal.subscribe(request).response.whenComplete { (result) in
            print(result, "subscribe complete")
            completion()
        }
    }
    
    func unsubscribe(clientId: String, completion: @escaping (() -> Void)){
        print("unsubscribe to \(clientId)")
        var request = Message_UnSubscribeRequest()
        request.clientID = clientId
        clientSignal.unSubscribe(request).response.whenComplete { (result) in
            print(result, "unsubscribe complete")
            completion()
        }
        
    }
}
