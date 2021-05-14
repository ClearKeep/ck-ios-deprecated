
import SwiftUI
import GoogleSignIn
import MSAL

struct LoginView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    @State var email: String = ""
    @State var password: String = ""
    @State var deviceID: String = ""
    
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    @State var isRegister: Bool = false
    @State var isForgotPassword: Bool = false
    @State var hudVisible = false
    @State var isShowAlert = false
    @State var messageAlert = ""
    
    @State private var isEmailValid : Bool = true
    @State private var isPasswordValid: Bool = true
    
    @State private var colorBorder = Color.gray
    
    @State private var errorMsgEmail = ""
    @State private var errorMsgPassword = ""
    
    @State var isShowOTPVerification: Bool = false
    @ObservedObject var passCodeModel = PassCodeInputModel(passCodeLength: 4)
    
    @ObservedObject var loginViewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { reader in
                    ScrollView(.vertical, showsIndicators: false, content: {
                        VStack(alignment: .center, spacing: 24) {
                            LogoIconView()
                                .padding(.top, 20)
                            
                            if loginViewModel.isUseCustomServer {
                                HStack(spacing: 4) {
                                    Image("Alert")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24, alignment: .center)
                                        .foregroundColor(AppTheme.colors.warningLight.color)
                                        
                                    Text("You are using custom server")
                                        .font(AppTheme.fonts.textSmall.font)
                                        .foregroundColor(AppTheme.colors.warningLight.color)
                                }
                            }  
                            
                            VStack(alignment: .leading, spacing: 24) {
                                
                                WrappedTextFieldWithLeftIcon("Email", leftIconName: "Mail", shouldShowBorderWhenFocused: false, keyboardType: UIKeyboardType.emailAddress, text: $email, errorMessage: $errorMsgEmail)
                                
                                WrappedSecureTextWithLeftIcon("Password",leftIconName: "Lock", shouldShowBorderWhenFocused: false, text: $password, errorMessage: $errorMsgPassword)
                                
                                ButtonAuth("Login") {
                                    loginWithEmailAndPassword()
                                }
                                
                                HStack {
                                    NavigationLink(destination: AdvanceServerSettingsView(isUseCustomServer: $loginViewModel.isUseCustomServer, customServerURL: $loginViewModel.customServerURL, customServerPort: $loginViewModel.customServerPort)) {
                                        Text("Advance Server Settings")
                                            .font(AppTheme.fonts.linkXSmall.font)
                                            .foregroundColor(AppTheme.colors.offWhite.color)
                                            .frame(height: 30)
                                    }
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: ForgotPassWordView()) {
                                        Text("Forgot password?")
                                            .font(AppTheme.fonts.linkXSmall.font)
                                            .foregroundColor(AppTheme.colors.offWhite.color)
                                            .frame(height: 30)
                                    }
                                }
                                .padding(.horizontal, 6)
                                
                                
                                Divider()
                                    .frame(height: 0.5)
                                    .background(AppTheme.colors.offWhite.color)
                                
                                VStack(alignment: .center, spacing: 24) {
                                    Text("Social Sign-in")
                                        .font(AppTheme.fonts.linkSmall.font)
                                        .foregroundColor(AppTheme.colors.offWhite.color)
                                    
                                    HStack(spacing: 40) {
                                        SocialSignInButton(signInType: .google)
                                        SocialSignInButton(signInType: .office365)
                                        SocialSignInButton(signInType: .facebook)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("Don't have an account?")
                                        .font(AppTheme.fonts.linkSmall.font)
                                        .foregroundColor(AppTheme.colors.offWhite.color)
                                    
                                    NavigationLink(destination: RegisterView()) {
                                        HStack {
                                            Spacer()
                                            Text("Sign up")
                                                .font(AppTheme.fonts.linkSmall.font)
                                                .foregroundColor(AppTheme.colors.offWhite.color)
                                                .frame(width: 254, height: 40, alignment: .center)
                                                .background(Color.clear)
                                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white, lineWidth: 2))
                                            Spacer()
                                        }
                                        .frame(width: UIScreen.main.bounds.width - 40, height: 30, alignment: .trailing)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            NavigationLink(
                                destination: PasscodeView(passCodeModel: self.passCodeModel, successCompletion: {
                                    let userInfo = loginViewModel.userLoginResponseInfo
                                    self.saveLoginInfoAndRegisterAddress(userID: userInfo.userId, displayName: userInfo.userDisplayName, email: userInfo.userEmail, signInType: userInfo.signInType)
                                }),
                                isActive: $isShowOTPVerification,
                                label: { EmptyView() })
                        }
                        .padding()
                        .padding(.vertical, 20)
                    })
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .hud(.waiting(.circular, "Waiting..."), show: hudVisible)
            .alert(isPresented: self.$isShowAlert, content: {
                Alert(title: Text("Login Error"),
                      message: Text(self.messageAlert),
                      dismissButton: .default(Text("OK")))
            })
            .onTapGesture {
                self.hideKeyboard()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.GoogleSignIn.FinishedWithResponse)) { (obj) in
                if let userInfo = obj.userInfo,
                   let user = userInfo["user"] as? GIDGoogleUser {
                    print("Google signin success for user \(user.profile.email ?? "")")
                    self.loginWithGoogleSignInResponse(gooleUser: user)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.MicrosoftSignIn.FinishedWithResponse)) { (obj) in
                if let userInfo = obj.userInfo,
                   let accessToken = userInfo["accessToken"] as? String {
                    print("Microsoft signin success with token \(accessToken)")
                    self.loginWithMicrosoftAccessToken(accessToken)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.FacebookSignIn.FinishedWithResponse)) { (obj) in
                if let userInfo = obj.userInfo,
                   let accessToken = userInfo["accessToken"] as? String {
                    print("Facebook signin success with token \(accessToken)")
                    self.loginWithFacebookAccessToken(accessToken)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.GoogleSignIn.FinishedWithError)) { (obj) in
                if let userInfo = obj.userInfo,
                   let error = userInfo["error"] as? Error {
                    print("Signin google error: \(error.localizedDescription)")
                    self.messageAlert = "Something went wrong"
                    self.isShowAlert = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.MicrosoftSignIn.FinishedWithError)) { (obj) in
                if let userInfo = obj.userInfo,
                   let error = userInfo["error"] as? Error {
                    print("Signin microsoft error: \(error.localizedDescription)")
                    self.messageAlert = "Something went wrong"
                    self.isShowAlert = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.FacebookSignIn.FinishedWithError)) { (obj) in
                if let userInfo = obj.userInfo,
                   let error = userInfo["error"] as? Error {
                    print("Signin facebook error: \(error.localizedDescription)")
                    self.messageAlert = "Something went wrong"
                    self.isShowAlert = true
                }
            }
            .keyboardAdaptive()
            .grandientBackground()
            .edgesIgnoringSafeArea(.all)
        }
    }
}

extension LoginView {
    
    private func register() {
        self.viewRouter.current = .register
    }
    
    private func registerWithGroup() {
        guard let deviceID: Int32 = Int32(deviceID),
              let myAccount = CKAccount(username: email, deviceId: deviceID, accountType: .none),
              let connectionDb = CKDatabaseManager.shared.database?.newConnection() else {
            print("DeviceID always number")
            return
        }
        let groupId: Int64 = 1234
        do {
            // save my Account
            connectionDb.readWrite { (transaction) in
                myAccount.save(with: transaction)
            }
            let ourSignalEncryptionMng = try CKAccountSignalEncryptionManager(accountKey: myAccount.uniqueId,
                                                                              databaseConnection: connectionDb)
            
            let address = SignalAddress(name: email, deviceId: deviceID)
            let groupSessionBuilder = SignalGroupSessionBuilder(context: ourSignalEncryptionMng.signalContext)
            let senderKeyName = SignalSenderKeyName(groupId: String(groupId), address: address)
            let signalSKDM = try groupSessionBuilder.createSession(with: senderKeyName)
            
            CKSignalCoordinate.shared.ourEncryptionManager = ourSignalEncryptionMng
            CKSignalCoordinate.shared.myAccount = myAccount
            
            Backend.shared.authenticator.registerGroup(byGroupId: groupId,
                                                       clientId: email,
                                                       deviceId: deviceID,
                                                       senderKeyData: signalSKDM.serializedData()) { (result, error) in
                print("Register group with result: \(result)")
                if result {
                    //                    Backend.shared.signalSubscrible(clientId: self.email)
                    self.viewRouter.current = .masterDetail
                }
            }
        } catch {
            print("Register group error: \(error)")
        }
    }
}

// MARK: - Google SignIn Button
extension LoginView {
    
    private func loginWithGoogleSignInResponse(gooleUser: GIDGoogleUser) {
        var request = Auth_GoogleLoginReq()
        request.idToken = gooleUser.authentication.idToken
        
        hudVisible = true
        Backend.shared.loginWithGoogleAccount(request) { (result, error) in
            self.didReceiveLoginResponse(result: result, error: error, signInType: .google)
        }
        SocialLogin.shared.signOutGoogleAccount()
    }
}


// MARK: - Microsoft SignIn Button
extension LoginView {
    
    private func loginWithMicrosoftAccessToken(_ accessToken: String) {
        print("MICROSIFT ACCESS TOKEN:\n\(accessToken)")
        var request = Auth_OfficeLoginReq()
        request.accessToken = accessToken
        
        hudVisible = true
        Backend.shared.loginWithMicrosoftAccount(request) { (result, error) in
            self.didReceiveLoginResponse(result: result, error: error, signInType: .microsoft)
        }
        SocialLogin.shared.signOutO365()
    }
}

// MARK: - Facebook SignIn Button
extension LoginView {
    
    private func loginWithFacebookAccessToken(_ accessToken: String) {
        print("Facebook ACCESS TOKEN:\n\(accessToken)")
        var request = Auth_FacebookLoginReq()
        request.accessToken = accessToken
        
        hudVisible = true
        Backend.shared.loginWithFacebookAccount(request) { (result, error) in
            self.didReceiveLoginResponse(result: result, error: error, signInType: .facebook)
        }
        SocialLogin.shared.signOutFacebookAccount()
    }
}

extension LoginView {
    
    private func loginWithEmailAndPassword() {
        self.isEmailValid = self.email.textFieldValidatorEmail()
        colorBorder = self.isEmailValid ? Color.gray : Color.red
        
        if self.email.isEmpty {
            self.messageAlert = "Email can't be empty"
            self.isShowAlert = true
            return
        } else if !self.isEmailValid {
            self.messageAlert = "Email is incorrect"
            self.isShowAlert = true
            return
        } else if self.password.isEmpty {
            self.isPasswordValid = false
            self.messageAlert = "Password can't be empty"
            self.isShowAlert = true
            return
        }
        
        var request = Auth_AuthReq()
        request.email = self.email
        request.password = self.password
        request.authType = 1    // Which values could be set here?
        
        hudVisible = true
        Backend.shared.login(request) { (result, error) in
            self.didReceiveLoginResponse(result: result, error: error, signInType: .email)
        }
    }
    
    private func didReceiveLoginResponse(result: Auth_AuthRes?, error: Error?, signInType: SocialLogin.SignInType) {
         if let result = result {
            if result.baseResponse.success {
                do {
                    let user = User(id: "", token: result.accessToken, hash: result.hashKey,displayName: "" , email: self.email)
                    UserDefaults.standard.setValue(result.refreshToken, forKey: Constants.keySaveRefreshToken)
                    try UserDefaults.standard.setObject(user, forKey: Constants.keySaveUser)
                    
                    Backend.shared.getLoginUserID { (userID, displayName, email) in
                        if userID.isEmpty {
                            print("getLoginUserID Empty")
                            UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
                            UserDefaults.standard.removeObject(forKey: Constants.keySaveRefreshToken)
                            hudVisible = false
                            self.messageAlert = "Something went wrong"
                            self.isShowAlert = true
                            return
                        }
                        
                        let dictOTP = UserDefaults.standard.dictionary(forKey: "OTPEnableInfoKey") as? [String:Bool] ?? [:]
                        let enable2Factor = dictOTP[userID] ?? false
                        
                        if enable2Factor {
                            hudVisible = false
                            loginViewModel.userLoginResponseInfo = UserLoginResponseInfo(userId: userID, userDisplayName: displayName, userEmail: email, signInType: signInType)
                            isShowOTPVerification = true
                        } else {
                            saveLoginInfoAndRegisterAddress(userID: userID, displayName: displayName, email: email, signInType: signInType)
                        }
                    }
                } catch {
                    hudVisible = false
                    print(error.localizedDescription)
                    UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
                    UserDefaults.standard.removeObject(forKey: Constants.keySaveRefreshToken)
                    self.messageAlert = "Something went wrong"
                    self.isShowAlert = true
                }
            } else {
                hudVisible = false
                self.isShowAlert = true
                self.messageAlert = result.baseResponse.errors.message
            }
        } else if let error = error {
            hudVisible = false
            print(error)
            self.messageAlert = "Something went wrong"
        }
    }
    
    private func saveLoginInfoAndRegisterAddress(userID: String, displayName: String, email: String, signInType: SocialLogin.SignInType) {
        do {
            var user = try UserDefaults.standard.getObject(forKey: Constants.keySaveUser, castTo: User.self)
            user.id = userID
            user.displayName = displayName
            user.email = email
            UserDefaults.standard.setValue(user.id, forKey: Constants.keySaveUserID)
            try UserDefaults.standard.setObject(user, forKey: Constants.keySaveUser)
           
            let address = SignalAddress(name: userID, deviceId: Int32(555))
            hudVisible = true
            Backend.shared.authenticator.register(address: address) { (result, error) in
                hudVisible = false
                if result {
                    loginForUser(clientID: userID)
                    SocialLogin.shared.saveSignInType(signInType)
                } else {
                    print("Register Key Error \(error?.localizedDescription ?? "")")
                    UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
                    UserDefaults.standard.removeObject(forKey: Constants.keySaveRefreshToken)
        
                    self.messageAlert = "Something went wrong"
                    self.isShowAlert = true
                }
            }
        } catch let error as NSError {
            print(error)
            hudVisible = false
        }
    }
    
    private func loginForUser(clientID : String) {
        hudVisible = true
        Backend.shared.authenticator.requestKey(byClientId: clientID) { (result, error, response) in
            hudVisible = false
            guard let dbConnection = CKDatabaseManager.shared.database?.newConnection() else { return }
            do {
                if let _ = response {
                    // save account
                    var myAccount: CKAccount?
                    dbConnection.readWrite({ (transaction) in
                        let accounts = CKAccount.allAccounts(withUsername: clientID,
                                                             transaction: transaction)
                        if accounts.count > 0 {
                            myAccount = accounts.first
                        } else {
                            myAccount?.save(with: transaction)
                        }
                    })
                    if let account = myAccount {
                        let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: account.uniqueId,
                                                                                        databaseConnection: dbConnection)
                        
                        CKSignalCoordinate.shared.myAccount = account
                        CKSignalCoordinate.shared.ourEncryptionManager = ourEncryptionManager
                        Backend.shared.signalSubscrible(clientId: account.username)
                        Backend.shared.notificationSubscrible(clientId: account.username)
                    }
                    if result {
                        Backend.shared.registerTokenDevice { (response) in
                            if response {
                                UserDefaults.standard.setValue(Date(), forKey: Constants.User.loginDate)
                                self.viewRouter.current = .tabview
                                
                                DispatchQueue.main.async {
                                    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                                    appDelegate?.askPermissionForRemoteNotification()
                                }
                            }else {
                                UserDefaults.standard.removeObject(forKey: Constants.keySaveUser)
                                self.messageAlert = "Something went wrong"
                                self.isShowAlert = true
                            }
                        }
                    }else {
                        print("requestKey Error: \(error?.localizedDescription ?? "")")
                    }
                }
            } catch {
                print("Login with error: \(error)")
            }
        }
    }
    
    private func updateUserInfo(responseUserKey: Signal_PeerGetClientKeyResponse, clientId: String) {
        guard let dbConnection = CKDatabaseManager.shared.database?.newConnection() else { return }
        do {
            // save account
            if let myAccount = CKAccount(username: responseUserKey.clientID, deviceId: responseUserKey.deviceID, accountType: .none) {
                // save account
                dbConnection.readWrite({ (transaction) in
                    myAccount.save(with:transaction)
                })
                
                let ourEncryptionManager = try CKAccountSignalEncryptionManager(accountKey: myAccount.uniqueId,
                                                                                databaseConnection: dbConnection)
                
                CKSignalCoordinate.shared.myAccount = myAccount
                CKSignalCoordinate.shared.ourEncryptionManager = ourEncryptionManager
                
                Backend.shared.registerTokenDevice { (response) in
                    if response {
                        hudVisible = false
                        self.viewRouter.current = .tabview
                    }
                }
            }
        } catch {
            print("Login with error: \(error)")
            hudVisible = false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
