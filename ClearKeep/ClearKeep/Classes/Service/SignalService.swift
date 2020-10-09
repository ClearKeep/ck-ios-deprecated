
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC


class SignalService {
    
    fileprivate let client: Signalc_SignalKeyDistributionClient
    
    fileprivate let authenticator: Authenticator
    
    
    init(_ client: Signalc_SignalKeyDistributionClient, _ authenticator: Authenticator) {
        self.client = client
        self.authenticator = authenticator
    }
    
    
}

extension SignalService {
    
    
    func listen(heard: @escaping ((String, Signalc_Publication) -> Void)) {
        
        let request: Signalc_SubscribeAndListenRequest = .with {
            $0.clientID = authenticator.clientID
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
                   _ completion: @escaping (Bool, Error?) -> Void) {
        
        print("subscribe to \(clientID)")
        
        let request: Signalc_SubscribeAndListenRequest = .with {
            $0.clientID = clientID
        }
        
        client.subscribe(request).response.whenComplete { (result) in
            print(result, "----")
        }
    }
}
