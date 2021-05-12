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
    
    @State private var errorMessage1 = ""
    @State private var errorMessage2 = ""
    @State private var errorMessage3 = ""
    @State private var errorMessage4 = "This field should not be empty"
    
    @State private var isFocus: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 100)
            
            RoundedRectangle(cornerRadius: 32)
                .frame(width: 100, height: 100, alignment: .center)
            .background(Color.blue)
            .clipShape(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
            )
                .shadow(color: .gray, radius: 3, x: 0, y: 3)
            
            VStack(spacing: 20) {
                
                
                
                CustomTextFieldWithLeftIcon("Input", leftIconName: "Mail", text: $text1, errorMessage: $errorMessage1) { (changed) in
                    print("\(changed)")
                    errorMessage1 = text1.isEmpty ? "This field should not be empty" : ""
                }
                
                WrappedTextFieldWithLeftIcon("Email", shouldShowBorderWhenFocused: false, keyboardType: UIKeyboardType.emailAddress, text: $text2, errorMessage: $errorMessage2, isFocused: $isFocus)
                
 
                WrappedTextFieldWithLeftIcon("Email", shouldShowBorderWhenFocused: false, keyboardType: UIKeyboardType.emailAddress, text: $text2, errorMessage: $errorMessage2, isFocused: $isFocus)
 }
            .embededInCardView()
            .padding()
        }
        .grandientBackground()
        //.background(Color.white)
    }
}

struct SwiftUIViewPreview_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIViewPreview()
    }
}


