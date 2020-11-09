
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
//        registerByAddress()
        registerWithGroup()
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
    
    private func registerWithGroup() {
        guard let deviceID: Int32 = Int32(deviceID),
              let myAccount = CKAccount(username: username, deviceId: deviceID, accountType: .none),
              let connectionDb = CKDatabaseManager.shared.database?.newConnection() else {
            print("DeviceID always number")
            return
        }
        let groupId = "test_group"
        do {
            let ourSignalEncryptionMng = try CKAccountSignalEncryptionManager(accountKey: myAccount.uniqueId,
                                                                              databaseConnection: connectionDb)
            
            let address = SignalAddress(name: username, deviceId: deviceID)
            let groupSessionBuilder = SignalGroupSessionBuilder(context: ourSignalEncryptionMng.signalContext)
            let senderKeyName = SignalSenderKeyName(groupId: groupId, address: address)
            let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
            
            CKSignalCoordinate.shared.ourEncryptionManager = ourSignalEncryptionMng
            CKSignalCoordinate.shared.myAccount = myAccount
            
            Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                       clientId: username,
                                                       deviceId: deviceID,
                                                       senderKeyData: signalSKDM.serializedData()) { (result, error) in
                print("Register group with result: \(result)")
                if result {
                    // save my Account
                    connectionDb.readWrite { (transaction) in
                        myAccount.save(with: transaction)
                    }
                    self.viewRouter.current = .masterDetail
                }
            }
        } catch {
            print("Register group error: \(error)")
        }
    }
}

extension LoginView {
    
    private func login() {
//        loginForUser()
        getSenderKeyInGroupTest()
    }
    
    private func loginForUser() {
        Backend.shared.authenticator.login(username) { (result, error, response) in
            guard let dbConnection = CKDatabaseManager.shared.database?.newConnection() else { return }
            do {
                if let receiveStore = response {
                    // save account
                    var myAccount: CKAccount?
                    dbConnection.readWrite({ (transaction) in
                        let accounts = CKAccount.allAccounts(withUsername: receiveStore.clientID,
                                                             transaction: transaction)
                        if accounts.count > 0 {
                            myAccount = accounts.first
                        }
                    })
                    if let account = myAccount {
                        let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: account.uniqueId,
                                                                                        databaseConnection: dbConnection)
                        
                        CKSignalCoordinate.shared.myAccount = account
                        CKSignalCoordinate.shared.ourEncryptionManager = ourEncryptionManager
                    }
                }
                
                if result {
                    self.viewRouter.current = .masterDetail
                }
            } catch {
                print("Login with error: \(error)")
            }
        }
    }
    
    private func getSenderKeyInGroupTest() {
        let groupId = "test_group"
        Backend.shared.authenticator.checkRegisterInGroup(groupId: groupId, clientId: username) { (result, error, response) in
            guard let dbConnection = CKDatabaseManager.shared.database?.newConnection() else { return }
            do {
                // save account
                var myAccount: CKAccount?
                dbConnection.readWrite({ (transaction) in
                    let accounts = CKAccount.allAccounts(withUsername: self.username, transaction: transaction)
                    if accounts.count > 0 {
                        myAccount = accounts.first
                    }
                })
                if let account = myAccount {
                    let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: account.uniqueId,
                                                                                    databaseConnection: dbConnection)
                    
                    CKSignalCoordinate.shared.myAccount = account
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
