
import Foundation
import Combine
import CryptoKit

import SwiftProtobuf
import NIO
import GRPC

class Backend: ObservableObject {
    
    static let shared = Backend()
    
    private let group: MultiThreadedEventLoopGroup
    
    private let client: GRPCClient
    
    private let connection: ClientConnection
    
    var authenticator: Authenticator
    
    
    init(host: String = "localhost", port: Int = 50051) {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        let configuration = ClientConnection.Configuration.init(target: .hostAndPort(host, port), eventLoopGroup: group)
        
        connection = ClientConnection(configuration: configuration)
        
        client = GRPC.AnyServiceClient(channel: connection)
        
        authenticator = Authenticator(client)
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
    
    
    func authenticated(signAddresss: SignalAddress, bundleStore: CKBundleStore, _ completion: @escaping (Bool, Error?) -> Void) {
       
        
    }
}
