
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

struct LogoIconView : View {
    
    var body: some View {
        Image("Logo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 120, height: 120, alignment: .center)
            .padding(.all, 40)
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
                .font(AppTheme.fonts.linkSmall.font)
                .foregroundColor(AppTheme.colors.primary.color)
                .frame(minWidth: 0, maxWidth: .infinity , minHeight: 40, idealHeight: 40)
                .background(AppTheme.colors.offWhite.color)
        }
        .cornerRadius(20)
    }
}

struct RoundedGradientButton: View {
    
    private var title: String
    private var fixedWidth: CGFloat?
    private var action: () -> Void
    
    init(_ title: String, fixedWidth: CGFloat?, action: @escaping() -> Void) {
        self.title = title
        self.action = action
        self.fixedWidth = fixedWidth
    }
    
    var body: some View {
        Button(action: action) {
            Image("background")
                .resizable()
                .frame(width: fixedWidth, height: 40, alignment: .center)
                .overlay(
                    Text(title)
                        .font(AppTheme.fonts.linkSmall.font)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                        
                )
        }
        .cornerRadius(20)
    }
}

struct PlainButton: View {
    
    private var title: String
    private var titleColor: Color
    private var action: () -> Void
    
    init(_ title: String, titleColor: Color = AppTheme.colors.primary.color, action: @escaping() -> Void) {
        self.title = title
        self.action = action
        self.titleColor = titleColor
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.fonts.linkSmall.font)
                .foregroundColor(titleColor)
        }
        .background(Color.clear)
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
