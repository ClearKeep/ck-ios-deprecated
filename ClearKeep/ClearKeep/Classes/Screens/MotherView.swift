

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
//            case .masterDetail: MasterDetailView().transition(.move(edge: .trailing))
//            case .profile: ProfileView()
//            case .register: RegisterView()
            case .home:
                //TabViewContainer().transition(.move(edge: .trailing))
                HomeMainView()
//            case .search: SearchPeopleView()
//            case .createRoom: CreateRoomView(isPresentModel: .constant(true))
            case .callVideo: CallView()
//            case .inviteMember: InviteMemberGroup()
            case .recentCreatedGroupChat: GroupChatView(groupName: viewRouter.recentCreatedGroupModel!.groupName, groupId: viewRouter.recentCreatedGroupModel!.groupID)
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
//        case masterDetail
//        case profile
//        case register
//        case search
//        case createRoom
        case callVideo
//        case inviteMember
        case recentCreatedGroupChat
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
    
    var recentCreatedGroupModel: GroupModel? = nil
}
