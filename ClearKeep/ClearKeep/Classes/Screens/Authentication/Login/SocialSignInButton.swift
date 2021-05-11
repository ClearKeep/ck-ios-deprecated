//
//  SocialSignInButton.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/5/21.
//

import SwiftUI

struct SocialSignInButton: View {
    var signInType: SignInType
    
    var body: some View {
        VStack {
            Button(action: signInType.action) {
                Image(signInType.iconName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24, alignment: .center)
                    .padding(.all, 15)
                    .background(AppTheme.colors.offWhite.color)
                    .clipShape(Circle())
            }
        }
    }
}

extension SocialSignInButton {
    
    enum SignInType {
        case google, office365, facebook
        
        var iconName: String {
            switch self {
            case .google: return "google"
            case .office365: return "office365"
            case .facebook: return "facebook"
            }
        }
        
        var title: String {
            switch self {
            case .google: return "Sign In with Google"
            case .office365: return "Sign In with Office 365"
            case .facebook: return "Sign In with Facebook"
            }
        }
        
        var titleColor: Color {
            switch self {
            case .google: return UIColor(hex: "#2F80ED").color
            case .office365: return UIColor(hex: "#DC3E15").color
            case .facebook: return UIColor(hex: "#3F65EC").color
            }
        }
        
        var action: () -> Void {
            switch self {
            case .google: return { SocialLogin.shared.attemptLoginGoogle() }
            case .office365: return { SocialLogin.shared.attemptLoginOffice365() }
            case .facebook: return { SocialLogin.shared.attemptLoginFacebook() }
             }
        }
    }
}

struct SocialSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        SocialSignInButton(signInType: .google)
    }
}
