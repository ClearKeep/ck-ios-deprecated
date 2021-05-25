
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
                        Debug.DLog("Error serializedData")
                        return
                    }
                    DispatchQueue.main.async {
                        Debug.DLog("heard from \(publication.fromClientID)")
                        heard(publication.fromClientID, response)
                    }
                }
                let status = try call.status.wait()
                Debug.DLog("listen finished: \(status)")
            } catch {
                Debug.DLog("listen failed", error.localizedDescription)
            }
        }
    }
    
    func subscribe(clientId: String, completion: @escaping (() -> Void)) {
        Debug.DLog("subscribe signal to \(clientId)")
        let request: Message_SubscribeRequest = .with {
            $0.clientID = clientId
        }
        let response = clientSignal.subscribe(request).response
        
        response.whenComplete { (result) in
            Debug.DLog("\(result) subscribe signal completed")
            completion()
        }
        response.whenFailure { error in
            Debug.DLog("\(error) subscribe signal failed")
        }
    }
    
    func unsubscribe(clientId: String, completion: @escaping (() -> Void)){
        Debug.DLog("unsubscribe signal to \(clientId)")
        var request = Message_UnSubscribeRequest()
        request.clientID = clientId
        
        let response = clientSignal.unSubscribe(request).response
        
        response.whenComplete { (result) in
            Debug.DLog("\(result) unsubscribe signal completed")
            completion()
        }
        response.whenFailure { error in
            Debug.DLog("\(error) unsubscribe signal failed")
        }
    }
}
