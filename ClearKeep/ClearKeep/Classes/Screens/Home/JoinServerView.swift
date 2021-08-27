//
//  JoinServerView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/27/21.
//

import SwiftUI

struct JoinServerView: View {
    @State private var text: String = ""
    @State private var errorMessage = ""
    
    var action: ObjectCompletion? = nil
    @State private var isShowAlert = false

    init(action: ObjectCompletion?) {
        self.action = action
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            VStack {
                Spacer()
                Text("To join a server, please type in the link of the server")
                    .font(AppTheme.fonts.textMedium.font)
                WrappedTextFieldWithLeftIcon("Server URL", text: $text, errorMessage: $errorMessage)
                
                RoundedGradientButton("Join", fixedWidth: nil, disable: .constant(text.isEmpty), action: {
                    if validate() {
                        action?(text)
                    }
                })
                
                Text("Tip: Ask your server admin to get the url to the server")
                    .font(AppTheme.fonts.textSmall.font)
                    .foregroundColor(AppTheme.colors.gray3.color)
                Spacer()
            }
            Spacer()
        }).alert(isPresented: $isShowAlert, content: {
            Alert(title: Text("Error"),
                  message: Text("Wrong server URL. Please try again"),
                  dismissButton: .default(Text("Close")))
        })
    }
    
    private func validate() -> Bool {
        guard let first = text.components(separatedBy: ":").first,
              let last = text.components(separatedBy: ":").last else {
            isShowAlert = true
            return false
        }
        
        let validated = first.textFieldValidatorURL() && (first != last) && text.last! != ":"
        isShowAlert = !validated
        
        return validated
    }
}

struct JoinServerView_Previews: PreviewProvider {
    static var previews: some View {
        JoinServerView(action: nil)
    }
}
