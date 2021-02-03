

import SwiftUI

import SwiftUI
import Combine

struct MotherView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            switch viewRouter.current {
            case .login:
                if CKExtensions.getUserToken().isEmpty {
                    LoginView()
                } else {
                    TabViewContainer().transition(.move(edge: .trailing))
                }
            case .masterDetail: MasterDetailView().transition(.move(edge: .trailing))
            case .profile: ProfileView()
            case .register: RegisterView(isPresentModel: .constant(true))
            case .tabview: TabViewContainer().transition(.move(edge: .trailing))
            case .search: SearchPeopleView()
//            case .createRoom: CreateRoomView(isPresentModel: .constant(true))
            case .history: HistoryChatView().environmentObject(RealmGroups()).environmentObject(RealmMessages())
            case .callVideo: CallView()
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
        case masterDetail
        case profile
        case register
        case tabview
        case search
//        case createRoom
        case history
        case callVideo
    }
    
    private static func initialPage() -> Page {
        
        return Backend.shared.authenticator.loggedIn() ? .masterDetail : .login
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
