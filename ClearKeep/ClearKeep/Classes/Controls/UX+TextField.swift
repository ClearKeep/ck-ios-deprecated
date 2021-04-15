//
//  UX+TextField.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/14/21.
//

import SwiftUI

struct CustomTextFieldWithLeftIcon: View {
    @Binding private var text: String
    @Binding private var errorMessage: String
    
    @State private var isActive = false
    
    private var title: String
    private var leftIconName: String
    private var onEditingChanged: BoolCompletion
    
    init(_ title: String, leftIconName: String, text: Binding<String>, errorMessage: Binding<String>, onEditingChanged: @escaping BoolCompletion) {
        self.title = title
        self.leftIconName = leftIconName
        self._text = text
        self._errorMessage = errorMessage
        self.onEditingChanged = onEditingChanged
    }
    
    var shouldShowError: Bool {
        return !errorMessage.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                Image(leftIconName)
                    .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                    .padding(.leading, 16)
                TextField(title, text: $text, onEditingChanged: { (isChange) in
                    onEditingChanged(isChange)
                    self.isActive = isChange
                })
                    .autocapitalization(.none)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.colors.black.color)
                    .disableAutocorrection(true)
                    .keyboardType(.default)
                    .textFieldStyle(MyTextFieldStyle())
            }
            .frame(height: 52)
            .background(shouldShowError ? AppTheme.colors.errorLight.color : AppTheme.colors.gray5.color)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(shouldShowError ? AppTheme.colors.error.color :  (isActive ? AppTheme.colors.black.color : AppTheme.colors.gray5.color), lineWidth: 2)
            )
            .padding(.horizontal, 2)
            
            if shouldShowError {
                HStack() {
                    Text(errorMessage)
                        .lineLimit(3)
                        .font(AppTheme.fonts.textXSmall.font)
                        .foregroundColor(AppTheme.colors.error.color)
                    
                    Spacer()
                }
            }
        }
    }
}

struct TextFieldContent : View {
    
    var key: String
    @Binding var value: String
    
    var body: some View {
        return TextField(key, text: $value)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct TextFieldProfile: View {
    var key: String
    @Binding var value: String
    @Binding var disable: Bool
    
    var body: some View {
        return TextField(key, text: $value)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .disabled(disable)
    }
}

struct TextFieldWithLeftIcon: View {
    @Binding private var text: String
    
    private var title: String
    private var leftIconName: String
    private var onEditingChanged: (Bool) -> Void
    
    init(_ title: String, leftIconName: String, text: Binding<String>, onEditingChanged: @escaping (Bool) -> Void) {
        self.title = title
        self._text = text
        self.leftIconName = leftIconName
        self.onEditingChanged = onEditingChanged
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(leftIconName)
                .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                .padding(.leading, 16)
            TextField(title, text: $text, onEditingChanged: onEditingChanged)
                .autocapitalization(.none)
                .font(AppTheme.fonts.textSmall.font)
                .foregroundColor(AppTheme.colors.black.color)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .textFieldStyle(MyTextFieldStyle())
        }
        .frame(height: 52)
        .background(AppTheme.colors.gray5.color)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}


/// Custom textfield with left icon, error message
struct InputTextField: View {
    @Binding private var text: String
    @Binding private var errorMessage: String
    @State private var isActive = false
    
    private var title: String
    private var leftIconName: String
    private var onEditingChanged: BoolCompletion
    
    init(_ title: String, leftIconName: String, text: Binding<String>, errorMessage: Binding<String>, onEditingChanged: @escaping BoolCompletion) {
        self.title = title
        self.leftIconName = leftIconName
        self._text = text
        self._errorMessage = errorMessage
        self.onEditingChanged = onEditingChanged
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(leftIconName)
                .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                .padding(.leading, 16)
            TextField(title, text: $text, onEditingChanged: { (isChange) in
                onEditingChanged(isChange)
                self.isActive = isChange
            })
                .autocapitalization(.none)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.colors.black.color)
                .disableAutocorrection(true)
                .keyboardType(.default)
                .textFieldStyle(MyTextFieldStyle())
        }
        .frame(height: 52)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.colors.black.color, lineWidth: isActive ? 2 : 0)
        )
        .padding(.horizontal, isActive ? 2 : 0)
    }
}

struct CustomSecureTextWithLeftIcon: View {
    @Binding private var text: String
    @Binding private var errorMessage: String
    
    @State private var isActive = false
    @State private var isSecured: Bool = true
    
    private var title: String
    private var leftIconName: String
    
    init(_ title: String, leftIconName: String, text: Binding<String>, errorMessage: Binding<String>) {
        self.title = title
        self._text = text
        self.leftIconName = leftIconName
        self._errorMessage = errorMessage
    }
    
    var shouldShowError: Bool {
        return !errorMessage.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                Image(leftIconName)
                    .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                    .padding(.leading, 16)
                
                Group {
                    if isSecured {
                        SecureField(title, text: $text)
                    } else {
                        TextField(title, text: $text)
                    }
                }
                .autocapitalization(.none)
                .font(AppTheme.fonts.textSmall.font)
                .foregroundColor(AppTheme.colors.black.color)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .textFieldStyle(MyTextFieldStyle())
                
                Button(action: {
                    self.isSecured.toggle()
                }) {
                    Image(self.isSecured ? "eye" : "eye-cross")
                        .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                        .padding(.trailing, 16)
                }
            }
            .frame(height: 52)
            .background(shouldShowError ? AppTheme.colors.errorLight.color : AppTheme.colors.gray5.color)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(shouldShowError ? AppTheme.colors.error.color :  (isActive ? AppTheme.colors.black.color : AppTheme.colors.gray5.color), lineWidth: 2)
            )
            .padding(.horizontal, 2)
            
            if shouldShowError {
                HStack() {
                    Text(errorMessage)
                        .lineLimit(3)
                        .font(AppTheme.fonts.textXSmall.font)
                        .foregroundColor(AppTheme.colors.error.color)
                    
                    Spacer()
                }
            }
        }
    }
}

struct SecureInputView: View {
    
    @Binding private var text: String
    @State private var isSecured: Bool = true
    private var title: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isSecured {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
            }
            Button(action: {
                isSecured.toggle()
            }) {
                Image(self.isSecured ? "eye" : "eye-cross")
                    .accentColor(.gray)
                    .padding()
            }
        }
    }
}


struct PasswordSecureField : View {
    
    @Binding var password: String
    
    var body: some View {
        return SecureField("", text: $password)
    }
}

struct SecureFieldWithLeftIcon: View {
    @Binding private var text: String
    @State private var isSecured: Bool = true
    
    private var title: String
    private var leftIconName: String
    
    init(_ title: String, leftIconName: String, text: Binding<String>) {
        self.title = title
        self._text = text
        self.leftIconName = leftIconName
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(leftIconName)
                .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                .padding(.leading, 16)
            
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .autocapitalization(.none)
            .font(AppTheme.fonts.textSmall.font)
            .foregroundColor(AppTheme.colors.black.color)
            .disableAutocorrection(true)
            .keyboardType(.emailAddress)
            .textFieldStyle(MyTextFieldStyle())
            
            Button(action: {
                self.isSecured.toggle()
            }) {
                Image(self.isSecured ? "eye" : "eye-cross")
                    .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                    .padding(.trailing, 16)
            }
        }
        .frame(height: 52)
        .background(AppTheme.colors.gray5.color)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
