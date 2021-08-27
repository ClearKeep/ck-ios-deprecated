//
//  AdvanceServerSettingsView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 11/05/2021.
//

import SwiftUI

struct AdvanceServerSettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var isUseCustomServer: Bool
    @Binding var customServerURL: String
    
    @State private var isShowAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 8) {
                Button(action: {
                    isUseCustomServer.toggle()
                }) {
                    Image(isUseCustomServer ? "Checkbox" : "Ellipse20")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                
                Text("Use Custom Server")
                    .font(AppTheme.fonts.linkSmall.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
                
                Spacer()
            }
            .padding(.top, 10)
            
            if isUseCustomServer {
                Text("Please enter your server URL to enter custom server")
                    .fontWeight(.medium)
                    .font(AppTheme.fonts.textSmall.font)
                    .foregroundColor(AppTheme.colors.background.color)
                
                    TextFieldProfile("Server URL", keyboardType: .URL, text: $customServerURL, onEditingChanged: {_ in
                    })
                
                DisableButton("Submit", disable: .constant(customServerURL.isEmpty)) {
                    useCustomServer()
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .applyNavigationBarPlainStyleLight(title: "Advanced Server Settings", leftBarItems: {
            Image("ic_back_white")
                .frame(width: 40, height: 40)
                .foregroundColor(AppTheme.colors.offWhite.color)
                .fixedSize()
                .scaledToFit()
                .onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
                }
        }, rightBarItems: {
            Spacer()
        })
        .grandientBackground()
        .alert(isPresented: self.$isShowAlert, content: {
            Alert(title: Text("Login Error"),
                  message: Text("Wrong server URL. Please try again"),
                  dismissButton: .default(Text("OK")))
        })
        .onTapGesture {
            self.hideKeyboard()
        }       
    }
    
    private func useCustomServer() {
        guard let first = customServerURL.components(separatedBy: ":").first,
              let last = customServerURL.components(separatedBy: ":").last else {
            isShowAlert = true
            return
        }
        
        let validated = first.textFieldValidatorURL() && (first != last) && customServerURL.last! != ":"
        isShowAlert = !validated
        
        if validated {

        }
    }
}

struct AdvanceServerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvanceServerSettingsView(isUseCustomServer: .constant(false), customServerURL: .constant(""))
    }
}
