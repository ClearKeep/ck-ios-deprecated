//
//  GoogleSignInButton.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/31/21.
//

import SwiftUI
import GoogleSignIn

// Button
struct GoogleSignInButton: UIViewRepresentable {
    let signBtn: GIDSignInButton
    
    func makeUIView(context: Context) -> GIDSignInButton {
        return signBtn
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {
    }
}

class GoogleSignInResponse {
    let user: GIDGoogleUser?
    let error: Error?
    
    init(user: GIDGoogleUser? = nil, error: Error? = nil) {
        self.user = user
        self.error = error
    }
}
