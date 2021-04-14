//
//  SwiftUIViewPreview.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/14/21.
//

import SwiftUI

struct SwiftUIViewPreview: View {
    @State private var text1 = ""
    @State private var text2 = ""
    @State private var text3 = ""
    @State private var text4 = ""
    //@State private var errorMessage = "@State private var errorMessage = some text here"
    @State private var errorMessage1 = ""
    @State private var errorMessage2 = ""
    @State private var errorMessage3 = ""
    @State private var errorMessage4 = "This field should not be empty"

    var body: some View {
        VStack(spacing: 20) {
            CustomTextFieldWithLeftIcon("Input", leftIconName: "Mail", text: $text1, errorMessage: $errorMessage1) { (changed) in
                print("\(changed)")
                errorMessage1 = text1.isEmpty ? "This field should not be empty" : ""
            }

            CustomTextFieldWithLeftIcon("Input", leftIconName: "Mail", text: $text2, errorMessage: $errorMessage2) { (changed) in
                print("\(changed)")
                errorMessage4 = text2.isEmpty ? "This field should not be empty" : ""
            }
            
            WrappedSecureTextWithLeftIcon("Wrapped TF", leftIconName: "Lock", text: $text3, errorMessage: $errorMessage3)

            CustomSecureTextWithLeftIcon("Input", leftIconName: "Lock", text: $text4, errorMessage: $errorMessage4)
            
            RoundedGradientButton("Sign up", fixedWidth: 120) {
                
            }
        }
        .embededInCardView()
        .padding()
        .grandientBackground()
        //.background(Color.white)
    }
}

struct SwiftUIViewPreview_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIViewPreview()
    }
}


