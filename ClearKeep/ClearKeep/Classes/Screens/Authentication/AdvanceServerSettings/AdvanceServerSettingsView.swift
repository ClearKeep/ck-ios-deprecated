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
    @Binding var customServerPort: String
    
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
                Text("Please enter your server URL and Port to enter custom server")
                    .fontWeight(.medium)
                    .font(AppTheme.fonts.textSmall.font)
                    .foregroundColor(AppTheme.colors.background.color)
                
                HStack(spacing: 16) {
                    TextFieldProfile("Server URL", keyboardType: .URL, text: $customServerURL, onEditingChanged: {_ in })
                    TextFieldProfile("Port", keyboardType: .numberPad, text: $customServerPort, onEditingChanged: {_ in })
                        .frame(width: 76)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .applyNavigationBarPlainStyleLight(title: "Advance Server Settings", leftBarItems: {
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
        .onTapGesture {
            self.hideKeyboard()
        }       
    }
}

struct AdvanceServerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvanceServerSettingsView(isUseCustomServer: .constant(false), customServerURL: .constant(""), customServerPort: .constant(""))
    }
}