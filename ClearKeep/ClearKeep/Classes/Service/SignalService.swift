
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC


class SignalService {
    
    fileprivate let client: Signalc_SignalKeyDistributionClient
    fileprivate let clientGroup: SignalcGroup_GroupSenderKeyDistributionClient
    
    
    init(_ client: Signalc_SignalKeyDistributionClient,
         clientGroup: SignalcGroup_GroupSenderKeyDistributionClient) {
        self.client = client
        self.clientGroup = clientGroup
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
    
    func listenGroup(username: String,
                     heard: @escaping ((String, SignalcGroup_GroupPublication) -> Void)) {
        let request: SignalcGroup_GroupSubscribeAndListenRequest = .with {
            $0.clientID = username
        }
        DispatchQueue.global(qos: .background).async {
            do {
                let call = self.clientGroup.listen(request) { publication in
                    guard let data = try? publication.serializedData(), let response = try? SignalcGroup_GroupPublication(serializedData: data) else {
                        print("Error serializedData")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        heard(publication.senderID, response)
                    }
                }
                
                let status = try call.status.wait()
                print("listen group finished: \(status)")
            } catch {
                print("Error", error.localizedDescription)
            }
        }
    }
    
    func subscribe(clientID: String) {
        print("subscribe to \(clientID)")
        let request: Signalc_SubscribeAndListenRequest = .with {
            $0.clientID = clientID
        }
        client.subscribe(request).response.whenComplete { (result) in
            print(result, "subscribe complete")
        }
    }
    
    func subscribeGroup(clientID: String) {
        print("subscribe to \(clientID)")
        let request: SignalcGroup_GroupSubscribeAndListenRequest = .with {
            $0.clientID = clientID
        }
        clientGroup.subscribe(request).response.whenComplete { (result) in
            print(result, "subscribeGroup complete")
        }
    }
}
