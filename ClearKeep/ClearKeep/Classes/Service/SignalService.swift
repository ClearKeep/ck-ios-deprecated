
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC


class SignalService {
    
    fileprivate let clientSignal: Signal_SignalKeyDistributionClient
    
    init(_ clientSignal: Signal_SignalKeyDistributionClient) {
        self.clientSignal = clientSignal
    }
}

extension SignalService {
        
    func listen(clientId: String, heard: @escaping ((String, Signal_Publication) -> Void)) {
        let request: Signal_SubscribeAndListenRequest = .with {
            $0.clientID = clientId
        }
        DispatchQueue.global(qos: .background).async {
            do {
                let call = self.clientSignal.listen(request) { publication in
                    guard let data = try? publication.serializedData(), let response = try? Signal_Publication(serializedData: data) else {
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
        let request: Signal_SubscribeAndListenRequest = .with {
            $0.clientID = clientId
        }
        clientSignal.subscribe(request).response.whenComplete { (result) in
            print(result, "subscribe complete")
            completion()
        }
    }
}
