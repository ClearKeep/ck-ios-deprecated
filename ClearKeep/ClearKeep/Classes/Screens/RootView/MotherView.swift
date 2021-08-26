

import SwiftUI
import Combine

struct MotherView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            switch viewRouter.current {
            case .login:
                LoginView(dismissAlert: .constant(true), joinServer: false)
            case .home:
                HomeMainView()
            }
        }
    }
}

struct MotherView_Previews : PreviewProvider {
    static var previews: some View {
        MotherView().environmentObject(ViewRouter())
    }
}

class ViewRouter: ObservableObject {
    enum Page {
        case login
        case home
    }
    
    private static func initialPage() -> Page {
        return CKExtensions.getUserToken().isEmpty ? .login : .home
    }
    
    let objectWillChange = PassthroughSubject<ViewRouter,Never>()
    var current: Page = ViewRouter.initialPage() {
        didSet {
            withAnimation() {
                DispatchQueue.main.async {
                    self.objectWillChange.send(self)
                }
            }
        }
    }
}
