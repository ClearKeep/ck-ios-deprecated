
import SwiftUI

struct TitleLabel : View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        return Text(text)
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding()//.bottom, 10)
    }
}

struct UserImage : View {
    let name: String

    var body: some View {
        return Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding()
    }
}

struct ButtonContent : View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        return Text(text)
            .font(.headline)
            .foregroundColor(.gray)
            .padding()
            .frame(width: 150, height: 50)
            .cornerRadius(10.0)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1)
        )
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


struct PasswordSecureField : View {

    @Binding var password: String

    var body: some View {
        return SecureField("Password", text: $password)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
