//
//  UX+WrappedTextField.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/14/21.
//

import SwiftUI

struct WrappedTextFieldWithLeftIcon: View {
    @Binding var text: String
    @Binding private var errorMessage: String
    @Binding private var isFocused: Bool
    
    private var title: String
    private var leftIconName: String
    private var shouldShowBorderWhenFocused: Bool
    private var keyboardType: UIKeyboardType
    
    init(_ title: String,
         leftIconName: String = "",
         shouldShowBorderWhenFocused: Bool = true,
         keyboardType: UIKeyboardType = .default,
         text: Binding<String>,
         errorMessage: Binding<String>,
         isFocused: Binding<Bool> = .constant(false))
    {
        self.title = title
        self.leftIconName = leftIconName
        self.shouldShowBorderWhenFocused = shouldShowBorderWhenFocused
        self.keyboardType = keyboardType
        
        self._text = text
        self._errorMessage = errorMessage
        self._isFocused = isFocused
    }
    
    var shouldShowError: Bool {
        return !errorMessage.isEmpty
    }
    
    var borderColor: Color {
        if shouldShowBorderWhenFocused {
            if shouldShowError {
                return AppTheme.colors.error.color
            } else {
                return isFocused ? AppTheme.colors.black.color : AppTheme.colors.gray5.color
            }
        } else {
            return AppTheme.colors.gray5.color
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                if !leftIconName.isEmpty {
                    Image(leftIconName)
                        .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                        .padding(.leading, 16)
                } else {
                    Spacer()
                        .frame(width: 14)
                }
                
                WrappedTextField(text: $text,
                                 isRevealed: .constant(true),
                                 isFocused: $isFocused,
                                 placeHolder: title,
                                 keyboardType: keyboardType)
                    .autocapitalization(.none)
                    .font(AppTheme.fonts.textSmall.font)
                    .foregroundColor(AppTheme.colors.black.color)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(MyTextFieldStyle())
                    .padding(.leading, 10)
                
            }
            .frame(height: 52)
            .background(shouldShowError ? AppTheme.colors.errorLight.color : AppTheme.colors.gray5.color)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 2)
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

struct WrappedSecureTextWithLeftIcon: View {
    @Binding var text: String
    @Binding private var errorMessage: String
    @Binding private var isFocused: Bool
    
    @State private var isRevealed = false
    
    private var title: String
    private var leftIconName: String
    private var shouldShowBorderWhenFocused: Bool
    private var keyboardType: UIKeyboardType
    
    init(_ title: String,
         leftIconName: String,
         shouldShowBorderWhenFocused: Bool = true,
         keyboardType: UIKeyboardType = .default,
         text: Binding<String>,
         errorMessage: Binding<String>,
         isFocused: Binding<Bool> = .constant(false))
    {
        self.title = title
        self.leftIconName = leftIconName
        self.shouldShowBorderWhenFocused = shouldShowBorderWhenFocused
        self.keyboardType = keyboardType
        
        self._text = text
        self._errorMessage = errorMessage
        self._isFocused = isFocused
    }
    
    var shouldShowError: Bool {
        return !errorMessage.isEmpty
    }
    
    var borderColor: Color {
        if shouldShowBorderWhenFocused {
            if shouldShowError {
                return AppTheme.colors.error.color
            } else {
                return isFocused ? AppTheme.colors.black.color : AppTheme.colors.gray5.color
            }
        } else {
            return AppTheme.colors.gray5.color
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                if !leftIconName.isEmpty {
                    Image(leftIconName)
                        .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                        .padding(.leading, 16)
                } else {
                    Spacer()
                        .frame(width: 14)
                }
                
                WrappedTextField(text: $text,
                                 isRevealed: $isRevealed,
                                 isFocused: $isFocused, placeHolder: title)
                    
                    .autocapitalization(.none)
                    .font(AppTheme.fonts.textSmall.font)
                    .foregroundColor(AppTheme.colors.black.color)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(MyTextFieldStyle())
                    .padding(.leading, 10)
                
                Button(action: {
                    self.isRevealed.toggle()
                }) {
                    Image(self.isRevealed ? "eye-cross" : "eye")
                        .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                        .padding(.trailing, 16)
                }
            }
            .frame(height: 52)
            .background(shouldShowError ? AppTheme.colors.errorLight.color : AppTheme.colors.gray5.color)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 2)
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

/// This is wrapped textfield from UIKit, don't use this directly outside of this file
fileprivate struct WrappedTextField: UIViewRepresentable {
    
    @Binding var text: String
    @Binding var isRevealed: Bool
    @Binding var isFocused: Bool
    
    var placeHolder: String
    var keyboardType: UIKeyboardType = .default
    
    func makeUIView(context: UIViewRepresentableContext<WrappedTextField>) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.isUserInteractionEnabled = true
        tf.delegate = context.coordinator
        tf.font = AppTheme.fonts.textSmall
        tf.textColor = AppTheme.colors.black
        tf.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: [NSAttributedString.Key.foregroundColor: AppTheme.colors.gray3])
        tf.keyboardType = keyboardType
        return tf
    }
    
    func makeCoordinator() -> WrappedTextField.Coordinator {
        return Coordinator(text: $text, isFocused: $isFocused)
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = !isRevealed
        uiView.placeholder = placeHolder
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool
        
        init(text: Binding<String>, isFocused: Binding<Bool>) {
            _text = text
            _isFocused = isFocused
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isFocused = true
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isFocused = false
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return false
        }
    }
}
