

import SwiftUI

import SwiftUI
import Combine

struct MotherView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        VStack {
            switch viewRouter.current {
            case .login:
                LoginView()
            case .tabview:
                HomeMainView().transition(.move(edge: .trailing))
            case .callVideo: CallView()
            case .recentCreatedGroupChat: RecentCreatedGroupChatView()
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
        case tabview
        case callVideo
        case recentCreatedGroupChat
    }
    
    private static func initialPage() -> Page {
        
        return CKExtensions.getUserToken().isEmpty ? .login : .tabview
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
    
    var recentCreatedGroupModel: GroupModel? = nil
}
