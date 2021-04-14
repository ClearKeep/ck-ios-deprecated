//
//  UX+WrappedTextField.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/14/21.
//

import SwiftUI

struct WrappedSecureTextWithLeftIcon: View {
    @Binding var text: String
    @Binding private var errorMessage: String
    
    @State private var isRevealed = false
    @State private var isFocused = false

    private var title: String
    private var leftIconName: String
    
    init(_ title: String, leftIconName: String, text: Binding<String>, errorMessage: Binding<String>) {
        self.title = title
        self.leftIconName = leftIconName
        self._text = text
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
                
                WrappedTextField(text: $text,
                            isRevealed: $isRevealed,
                            isFocused: $isFocused, placeHolder: title)
                    
                .autocapitalization(.none)
                .font(AppTheme.fonts.textSmall.font)
                .foregroundColor(AppTheme.colors.black.color)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .textFieldStyle(MyTextFieldStyle())
                
                Button(action: {
                    self.isRevealed.toggle()
                }) {
                    Image(self.isRevealed ? "eye" : "eye-cross")
                        .foregroundColor(AppTheme.colors.textFieldIconTint.color)
                        .padding(.trailing, 16)
                }
            }
            .frame(height: 52)
            .background(shouldShowError ? AppTheme.colors.errorLight.color : AppTheme.colors.gray5.color)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(shouldShowError ? AppTheme.colors.error.color :  (isFocused ? AppTheme.colors.black.color : AppTheme.colors.gray5.color), lineWidth: 2)
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

struct WrappedTextField: UIViewRepresentable {

    @Binding var text: String
    @Binding var isRevealed: Bool
    @Binding var isFocused: Bool
    
    var placeHolder: String

    func makeUIView(context: UIViewRepresentableContext<WrappedTextField>) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.isUserInteractionEnabled = true
        tf.delegate = context.coordinator
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
