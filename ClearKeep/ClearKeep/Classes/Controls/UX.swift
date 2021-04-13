
import SwiftUI

typealias VoidCompletion = () -> Void
typealias BoolCompletion = (Bool) -> Void
typealias ObjectCompletion = (Any?) -> Void

struct TitleLabel : View {
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        return Text(text)
            .font(.title)
            .fontWeight(.semibold)
            .padding()//.bottom, 10)
    }
}

struct TitleTextField : View {
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        return Text(text)
            .font(.system(size: 15))
            .fontWeight(.semibold)
            .padding(.bottom, 5)
    }
}

struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(PlainTextFieldStyle())
            .padding(.leading , 10)
    }
}

struct UserImage : View {
    let name: String
    
    var body: some View {
        return Image(name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.size.width / 3, height: UIScreen.main.bounds.size.width / 3)
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
            .font(.system(size: 17))
            .foregroundColor(.gray)
            .padding()
            .frame(width: UIScreen.main.bounds.size.width / 3, height: 50)
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
                .foregroundColor(Constants.Color.colorIcon.color)
                .padding(.leading, 16)
            TextField(title, text: $text, onEditingChanged: onEditingChanged)
                .autocapitalization(.none)
                .font(.system(size: 16))
                .foregroundColor(Color.black)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)
                .textFieldStyle(MyTextFieldStyle())
        }
        .frame(height: 52)
        .background(Color.white)
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

struct ButtonAuth: View {
    
    private var title: String
    private var action: () -> Void
    
    init(_ title: String, action: @escaping() -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .fontWeight(.bold)
                .foregroundColor(Constants.Color.primary.color)
                .frame(minWidth: 0, maxWidth: .infinity , minHeight: 40, idealHeight: 40)
                .background(Constants.Color.grayScale.color)
        }
        .cornerRadius(20)
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

struct MultipleSelectionRow: View {
    
    var people: People
    
    @Binding var selectedItems: Set<People>
    
    var isSelected: Bool {
        selectedItems.contains(people)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.top, 6)
                .padding(.bottom, 6)
                .padding(.horizontal)
            Text(self.people.userName)
                .font(.body)
                
                .fontWeight(.bold)
            Spacer()
            if self.isSelected {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.blue)
            }
        }.onTapGesture(count: 1, perform: {
            if self.isSelected {
                self.selectedItems.remove(self.people)
            } else {
                self.selectedItems.insert(self.people)
            }
        })
    }
}
