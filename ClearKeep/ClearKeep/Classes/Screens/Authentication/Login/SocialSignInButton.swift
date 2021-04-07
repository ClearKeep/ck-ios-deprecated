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
                HStack(spacing: 0) {
                    Image(signInType.iconName)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24, alignment: .center)
                        .padding(.all, 12)
                        .background(RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white)
                                        .frame(width: 44, height: 44, alignment: .center))
                    
                    Text(signInType.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color("Blue-2"))
//                        .shadow(color: .primary, radius: 2, x: 0, y: 2)
                )
                .padding(.all, 8)
            }
        }
    }
}

extension SocialSignInButton {
    
    enum SignInType {
        case google, office365
        
        var iconName: String {
            switch self {
            case .google: return "google"
            case .office365: return "office365"
            }
        }
        
        var title: String {
            switch self {
            case .google: return "Sign in with Google"
            case .office365: return "Sign in with Office365"
            }
        }
        
        var action: () -> Void {
            switch self {
            case .google: return { SocialLogin.shared.attemptLoginGoogle() }
            case .office365: return { SocialLogin.shared.attemptLoginOffice365() }
            }
        }
    }
}

struct SocialSignInButton_Previews: PreviewProvider {
    static var previews: some View {
        SocialSignInButton(signInType: .google)
    }
}
