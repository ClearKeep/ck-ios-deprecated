
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC


class SignalService {
    
    fileprivate let client: Signalc_SignalKeyDistributionClient
    
    
    init(_ client: Signalc_SignalKeyDistributionClient) {
        self.client = client
    }

    
}

extension SignalService {
    
    
    func listen(username: String, heard: @escaping ((String, Signalc_Publication) -> Void)) {
        
        let request: Signalc_SubscribeAndListenRequest = .with {
            $0.clientID = username
        }
        
        DispatchQueue.global(qos: .background).async {
            
            do {
                let call = self.client.listen(request) { publication in
                    
                    guard let data = try? publication.serializedData(), let response = try? Signalc_Publication(serializedData: data) else {
                        print("Error serializedData")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        heard(publication.senderID, response)
                    }
                }
                
                let status = try call.status.wait()
                print("listen finished: \(status)")
            } catch {
                
                print("Error", error.localizedDescription)
            }
        }
    }
    
    
    
    func subscribe(clientID: String,
                   _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void) {
        
        print("subscribe to \(clientID)")
        
        let request: Signalc_SubscribeAndListenRequest = .with {
            $0.clientID = clientID
        }
        
        client.subscribe(request).response.whenComplete { (result) in
            print(result, "----")
        }
    }
}
