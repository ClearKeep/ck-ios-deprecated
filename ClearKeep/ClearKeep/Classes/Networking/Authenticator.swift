
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC

class Authenticator {
    
    private let client: Signalc_SignalKeyDistributionClient
    
    var clientID: String = ""
    
    
    init(_ client: Signalc_SignalKeyDistributionClient) {
        self.client = client
    }
    
    
    // call register
    private func authenticate(signalAddess: SignalAddress,
                      bundleStore: CKBundleStore,
                      _ completion: @escaping (Bool, Error?) -> Void,
                      submit: @escaping (Signalc_SignalRegisterKeysRequest, CallOptions?)
                        -> UnaryCall<Signalc_SignalRegisterKeysRequest, Signalc_BaseResponse>) {
        
        
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
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    completion(true, nil)
                case .failure(_):
                    self.nauthenticate(completion)
                }
            }
        }
    }
    
    
    
    private func authenticated(cliendID: String,
                               _ completion: @escaping (Bool, Error?) -> Void) {
        
        self.clientID = cliendID
        Backend.shared.authenticated(completion)
    }
    
    
    private func nauthenticate(_ completion: @escaping (Bool, Error?) -> Void) {
        print("auth failed")
        clientID = ""
        completion(false, nil)
    }
    
    
    private func login(_ clientID: String,
               _ completion: @escaping (Bool, Error?) -> Void,
               submit: @escaping (Signalc_SignalKeysUserRequest, CallOptions?)
                -> UnaryCall<Signalc_SignalKeysUserRequest, Signalc_SignalKeysUserResponse>) {
        
        let request: Signalc_SignalKeysUserRequest = .with {
            $0.clientID = clientID
        }
        
        submit(request, nil).response.whenComplete { (result) in

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    self.clientID = response.clientID
                    self.authenticated(cliendID: self.clientID,
                                       completion)
                completion(true, nil)
                case .failure(_):
                    self.nauthenticate(completion)
                }
            }
        }
    }
    
}

extension Authenticator {
    
    func register(_ signalAddess: SignalAddress, bundleStore: CKBundleStore, completion: @escaping (Bool, Error?) -> Void) {
        authenticate(signalAddess: signalAddess, bundleStore: bundleStore, completion, submit: client.registerBundleKey)
    }
    
}

extension Authenticator {
    
    func login(_ clientID: String, _ completion: @escaping (Bool, Error?) -> Void) {
        
        login(clientID, completion, submit: client.getKeyBundleByUserId)
    }
}
