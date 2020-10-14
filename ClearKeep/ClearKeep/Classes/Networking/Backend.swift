
import Foundation
import Combine
import CryptoKit

import SwiftProtobuf
import NIO
import GRPC

class Backend: ObservableObject {
    
    static let shared = Backend()
    
    private let group: MultiThreadedEventLoopGroup
    
    private let client: Signalc_SignalKeyDistributionClient
    
    private let connection: ClientConnection
    
    var authenticator: Authenticator
    
    var signalService: SignalService
    
    
    init(host: String = "localhost", port: Int = 50051) {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        let configuration = ClientConnection.Configuration.init(target: .hostAndPort(host, port), eventLoopGroup: group)
        
        connection = ClientConnection(configuration: configuration)
        
        client = Signalc_SignalKeyDistributionClient(channel: connection)
        
        authenticator = Authenticator(client)
        
        signalService = SignalService(client, authenticator)
    }
    
    deinit {
        try? group.syncShutdownGracefully()
    }
    

    
    func close() {
        _ = connection.close()
    }
    
    
    static func log(_ string: String) {
        DispatchQueue.main.async {
            print(string)
        }
    }
    
    
    func authenticated(_ completion: @escaping (Any?, Error?) -> Void) {
       
//        signalService.listen(heard: heard)
        signalService.subscribe(clientID: authenticator.clientID, completion)
        
    }
    
//    func heard(_ senderId: String, _ response: Signalc_Publication) {
//        print(senderId ?? "test")
//        print(response ?? "test")
//
//    }
}
