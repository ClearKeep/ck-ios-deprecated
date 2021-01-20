
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
