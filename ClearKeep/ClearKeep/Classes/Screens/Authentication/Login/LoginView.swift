
import SwiftUI

struct LoginView: View {
    
    @State var username: String = ""
    @State var deviceID: String = ""

    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    @EnvironmentObject var viewRouter: ViewRouter
    
    
    var body: some View {
        VStack {
            TitleLabel("ClearKeep")
            UserImage(name: "phone")
            TextFieldContent(key: "Username", value: $username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            TextFieldContent(key: "DeviceID", value: $deviceID)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            HStack {
                Button(action: login) {
                    ButtonContent("LOGIN")
                    .padding(.trailing, 25)
                }
                Button(action: register) {
                    ButtonContent("REGISTER")
                }
            }
        }
        .padding()
    }
    
}

extension LoginView {
    
    private func register() {
        registerByAddress()
//        registerOld()
    }
    
    private func registerOld() {
        guard let deviceID: Int32 = Int32(deviceID) else {
            print("DeviceID always number")
            return
        }
        
        let clientStore = CKClientStore.init(clientID: username, deviceID: deviceID)

        Backend.shared.authenticator.clientStore = clientStore

        Backend.shared.authenticator.register(bundleStore: clientStore) { (result, error) in
            print(result)

            if result {
                self.viewRouter.current = .masterDetail
            }
        }
    }
    
    private func registerByAddress() {
        guard let deviceID: Int32 = Int32(deviceID) else {
            print("DeviceID always number")
            return
        }
        let address = SignalAddress(name: username, deviceId: Int32(deviceID))
        Backend.shared.authenticator.register(address: address) { (result, error) in
            print("Register result: \(result)")
            if result {
                self.viewRouter.current = .masterDetail
            }
        }
    }
}

extension LoginView {
    
    private func login() {
//        guard let deviceID: Int32 = Int32(deviceID) else {
//            print("DeviceID always number")
//            return
//        }
//        let clientStore = CKClientStore.init(clientID: username, deviceID: deviceID)
//        Backend.shared.authenticator.clientStore = clientStore
        Backend.shared.authenticator.login(username) { (result, error, response) in
            guard let dbConnection = CKDatabaseManager.shared.database?.newConnection() else { return }
            do {
                if let receiveStore = response,
                   let myAccount = CKAccount(username: receiveStore.clientID, accountType: .none) {
                    // save account
                    dbConnection.readWrite({ (transaction) in
                        myAccount.save(with:transaction)
                    })
                    
                    let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: myAccount.uniqueId, databaseConnection: dbConnection)
                    
                    let _ = try ourEncryptionManager.generateOutgoingBundle(1)

                    CKSignalCoordinate.shared.myAccount = myAccount
                    CKSignalCoordinate.shared.ourEncryptionManager = ourEncryptionManager
                }
                
                if result {
                    self.viewRouter.current = .masterDetail
                }
            } catch {
                print("Login with error: \(error)")
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
