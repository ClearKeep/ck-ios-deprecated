
import Foundation
import Combine

import SwiftProtobuf
import NIO
import GRPC

class Authenticator {
    
    private let client: Signalc_SignalKeyDistributionClient
    
    var recipientStore: Signalc_SignalKeysUserResponse?
    
    var recipientID: String = ""
    
    var clientStore: CKClientStore!
    
    init(_ client: Signalc_SignalKeyDistributionClient) {
        self.client = client
    }
    
    func loggedIn() -> Bool {
        
        if clientStore == nil {
            return false
        }
        
        return true
    }
    
    // call register
    private func authenticate(bundleStore: CKClientStore,
                              _ completion: @escaping (Bool, Error?) -> Void,
                              submit: @escaping (Signalc_SignalRegisterKeysRequest, CallOptions?)
                                -> UnaryCall<Signalc_SignalRegisterKeysRequest, Signalc_BaseResponse>) {
        
        
        let request: Signalc_SignalRegisterKeysRequest = .with {
            $0.clientID = bundleStore.address.name
            $0.deviceID = bundleStore.address.deviceId
            $0.registrationID = bundleStore.localRegistrationId
            $0.identityKeyPublic = bundleStore.identityKeyPair.publicKey
            $0.preKeyID = Int32(bundleStore.preKey1.preKeyId)
            $0.preKey = bundleStore.preKey1.serializedData()!
            $0.signedPreKeyID = Int32(bundleStore.signedPreKey.preKeyId)
            $0.signedPreKey = bundleStore.signedPreKey.serializedData()!
            $0.signedPreKeySignature = bundleStore.signedPreKey.signature
        }
        
        submit(request, nil).response.whenComplete { (result) in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    completion(true, nil)
                case .failure(_):
                    self.authenticated(cliendID: "") { (_, _, _) in
                        
                    }
                }
            }
        }
    }
    
    // call register
    private func registerUser(byAddress address: SignalAddress,
                              _ completion: @escaping (Bool, Error?) -> Void,
                              submit: @escaping (Signalc_SignalRegisterKeysRequest, CallOptions?)
                                -> UnaryCall<Signalc_SignalRegisterKeysRequest, Signalc_BaseResponse>) {
        
        if let connectionDb = CKDatabaseManager.shared.database?.newConnection() {
            do {
                let ourSignalEncryptionMng = try CKAccountSignalEncryptionManager(accountKey: address.name,
                                                                              databaseConnection: connectionDb)
                let clientId = address.name
                let ckBundle = try ourSignalEncryptionMng.generateOutgoingBundle(10)
                let preKey = ckBundle.preKeys.first
                CKSignalCoordinate.shared.ourEncryptionManager = ourSignalEncryptionMng
                
                // set parameters request register account
                let request: Signalc_SignalRegisterKeysRequest = .with {
                    $0.clientID = clientId
                    $0.deviceID = Int32(ckBundle.deviceId)
                    $0.registrationID = Int32(ourSignalEncryptionMng.registrationId)
                    $0.identityKeyPublic = ckBundle.identityKey
                    $0.preKeyID = Int32(preKey!.preKeyId)
                    $0.preKey = preKey!.publicKey
                    $0.signedPreKeyID = Int32(ckBundle.signedPreKey.preKeyId)
                    $0.signedPreKey = ckBundle.signedPreKey.publicKey
                    $0.signedPreKeySignature = ckBundle.signedPreKey.signature
                }
                
                submit(request, nil).response.whenComplete { (result) in
                    
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            print(response)
                            completion(true, nil)
                        case .failure(_):
                            self.authenticated(cliendID: "") { (_, _, _) in
                                
                            }
                        }
                    }
                }
            } catch {
                print("registerUser error: \(error.localizedDescription)")
            }
        }
    }
    
    
    private func authenticated(cliendID: String,
                               _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void) {
        
        if recipientID.isEmpty || recipientStore == nil {
            Backend.shared.authenticated(completion)
        }
    }
    
    
    private func nauthenticate(_ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void) {
        print("auth failed")
        recipientID = ""
        completion(false, nil, nil)
    }
    
    
    private func login(_ clientID: String,
               _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void,
               submit: @escaping (Signalc_SignalKeysUserRequest, CallOptions?)
                -> UnaryCall<Signalc_SignalKeysUserRequest, Signalc_SignalKeysUserResponse>) {
        
        let request: Signalc_SignalKeysUserRequest = .with {
            $0.clientID = clientID
        }
        
        submit(request, nil).response.whenComplete { (result) in

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
//                    self.authenticated(cliendID: response.clientID,
//                                       completion)
                    Backend.shared.subscrible(username: clientID, completion: completion)
                completion(true, nil, response)
                case .failure(_):
                    self.nauthenticate(completion)
                }
            }
        }
    }
    
    private func requestKey(byClientID clientID: String,
               _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void,
               submit: @escaping (Signalc_SignalKeysUserRequest, CallOptions?)
                -> UnaryCall<Signalc_SignalKeysUserRequest, Signalc_SignalKeysUserResponse>) {
        
        let request: Signalc_SignalKeysUserRequest = .with {
            $0.clientID = clientID
        }
        
        submit(request, nil).response.whenComplete { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                self.authenticated(cliendID: response.clientID,
                                       completion)
                completion(true, nil, response)
                case .failure(_):
                completion(false, nil, nil)
                }
            }
        }
    }
    
}

extension Authenticator {
    
    func register(bundleStore: CKClientStore, completion: @escaping (Bool, Error?) -> Void) {
        authenticate(bundleStore: bundleStore, completion, submit: client.registerBundleKey)
    }
    
    func register(address: SignalAddress, completion: @escaping (Bool, Error?) -> Void) {
        registerUser(byAddress: address, completion, submit: client.registerBundleKey)
    }
    
}

extension Authenticator {
    
    func login(_ clientID: String, _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void) {
        login(clientID, completion, submit: client.getKeyBundleByUserId)
    }
}

extension Authenticator {
    
    func requestKey(byClientID clientID: String, _ completion: @escaping (Bool, Error?, Signalc_SignalKeysUserResponse?) -> Void) {
        requestKey(byClientID: clientID, completion, submit: client.getKeyBundleByUserId)
    }
}

