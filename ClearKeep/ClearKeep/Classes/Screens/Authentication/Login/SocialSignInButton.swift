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
                HStack(alignment: .center, spacing: 4) {
                    Spacer()
                    
                    Text(signInType.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(signInType.titleColor)
                        .padding(.leading, 8)
                    
                    Image(signInType.iconName)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24, alignment: .center)
                        .padding(.all, 8)
                    
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
//                        .shadow(color: .primary, radius: 2, x: 0, y: 2)
                )
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
            case .google: return "Sign In with Google"
            case .office365: return "Sign In with Office 365"
            }
        }
        
        var titleColor: Color {
            switch self {
            case .google: return UIColor(hex: "#2F80ED").color
            case .office365: return UIColor(hex: "#DC3E15").color
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
        SocialSignInButton(signInType: .office365)
    }
}
