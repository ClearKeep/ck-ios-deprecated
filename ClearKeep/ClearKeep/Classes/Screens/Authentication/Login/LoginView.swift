
import SwiftUI

struct LoginView: View {
    
    @State var username: String = ""
    @State var password: String = ""

    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
//    @EnvironmentObject var viewRouter: ViewRouter
    
    
    var body: some View {
        VStack {
            TitleLabel("ClearKeep")
            UserImage(name: "phone")
            TextFieldContent(key: "Username", value: $username)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            PasswordSecureField(password: $password)
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
        
        let signalAddress = SignalAddress(identifier: "bob", deviceId: 111)

        let bobStore = CKBundleStore()

        do {

            let prekey = try bobStore.createPreKeys(count: 1)[0]

            try bobStore.preKeyStore.store(preKey: prekey, for: 11)

            ///
            let signedPreKey = try bobStore.updateSignedPrekey()

            try bobStore.signedPreKeyStore.store(signedPreKey: signedPreKey, for: 22)

        } catch {
            print(error.localizedDescription)
        }
        
        
        Backend.shared.authenticator.register(signalAddress, bundleStore: bobStore) { (result, error) in
            
        }
    }
    
}

extension LoginView {
    
    private func login() {
        
        Backend.shared.authenticator.login("bob") { (result, error) in
            
            
        }
    }

}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
