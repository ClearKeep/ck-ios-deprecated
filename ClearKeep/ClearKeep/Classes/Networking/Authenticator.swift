
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC

class Authenticator {
    
    private let client: GRPCClient
    
    
    init(_ client: GRPCClient) {
        self.client = client

    }
    
    
    private func authenticate(signalAddess: SignalAddress = SignalAddress(identifier: "bob", deviceId: 1),
                      bundleStore: CKBundleStore = CKBundleStore(),
                      _ completion: @escaping (Bool, Error?) -> Void,
                      submit: @escaping (Signalc_SignalRegisterKeysRequest, CallOptions?)
                        -> UnaryCall<Signalc_SignalRegisterKeysRequest, Signalc_SignalKeysUserResponse>) {
        
        
        let request: Signalc_SignalRegisterKeysRequest = .with {
            $0.clientID = signalAddess.identifier
            $0.deviceID = Int32(signalAddess.deviceId)
            $0.identityKeyPublic = try! bundleStore.identityKeyStore.getIdentityKeyPublicData()
            $0.registrationID = Int32(bundleStore.preKeyStore.lastId)
            $0.preKey = try! bundleStore.preKeyStore.preKey(for: bundleStore.preKeyStore.lastId)
            $0.signedPreKeyID = Int32(bundleStore.signedPreKeyStore.lastId)
            $0.signedPreKey = try! bundleStore.signedPreKeyStore.signedPreKey(for: bundleStore.signedPreKeyStore.lastId)
        }
        
        submit(request, nil).response.whenComplete { (result) in
            
            print(result)
            self.authenticated (completion)
        }
    }
    
    
    func authenticated(_ completion: @escaping (Bool, Error?) -> Void) {

      
    }
}
