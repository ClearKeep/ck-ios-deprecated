
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC
import SignalProtocolObjC

class Backend: ObservableObject {
    
    static let shared = Backend()
    
    private let group: MultiThreadedEventLoopGroup
    
    private let clientSignal: Signal_SignalKeyDistributionClient
    
    private let connection: ClientConnection
    
    var authenticator: Authenticator
    
    var signalService: SignalService?
    
    private var queueHandShake: [String: String] = [:]
    
    
    @Published var messages: [PostModel] = []
    @Published var rooms = [RoomModel]()
    
    
    init(host: String = "172.16.1.41", port: Int = 5000) {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        let configuration = ClientConnection.Configuration.init(target: .hostAndPort(host, port), eventLoopGroup: group)
        
        connection = ClientConnection(configuration: configuration)
        
        clientSignal = Signal_SignalKeyDistributionClient(channel: connection)
        
        authenticator = Authenticator(clientSignal)
        
        signalService = SignalService(clientSignal)
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
    
    func signalSubscrible(clientId: String) -> Void {
        signalService?.subscribe(clientId: clientId, completion: { [weak self] in
            self?.signalService?.listen(clientId: clientId, heard: self!.heard)
        })
    }
    
    private func heard(_ clienId: String, publication: Signal_Publication) {
        let userInfo: [String : Any] = ["clientId": clienId, "publication": publication]
        NotificationCenter.default.post(name: NSNotification.Name("DidReceiveSignalMessage"),
                                        object: nil,
                                        userInfo: userInfo)
        
    }
    
    func send(_ message: Data,
              fromClientId senderId: String,
              toClientId receiveId: String = "",
              groupId: String = "",
              _ completion: @escaping (Bool, Error?) -> Void) {
        do {
            let request: Signal_PublishRequest = .with {
                $0.clientID = receiveId
                $0.fromClientID = senderId
                $0.message = message
                $0.groupID = groupId
            }
            
            try self.sendMessage(request)
            
        } catch {
            print(error.localizedDescription)
        }
    }
        
    private func sendMessage(_ request: Signal_PublishRequest,
                        _ completion: ((Bool, Error?) -> Void)? = nil) throws {
        
        clientSignal.publish(request).response.whenComplete { result in
            switch result {
            case .success(let response):
                print(response)
                completion?(false, nil)
            case .failure(let error):
                print(error)
                completion?(false, error)
            }
        }
    }
}


struct PostModel: Identifiable {
    let id: Int8 = 11
    var newID = UUID().uuidString
    var from: String
    var message: Data
}

struct RoomModel: Identifiable, Hashable {
    var id: String

}
