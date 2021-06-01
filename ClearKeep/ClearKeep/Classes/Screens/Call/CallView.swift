
import SwiftUI

struct CallView: View {
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        Group {
            if viewModel.callGroup {
                GroupCallView(viewModel: viewModel)
            } else {
                PeerCallView(viewModel: viewModel)
            }
        }
        .grandientBackground()
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: {
            if let callBox = CallManager.shared.calls.first {
                viewModel.updateCallBox(callBox: callBox)
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Notification), perform: { (obj) in
            viewModel.didReceiveMessageGroup(userInfo: obj.userInfo)
        })
    }
}

struct CallView_Previews: PreviewProvider {
    static var previews: some View {
        CallView(viewModel: CallViewModel())
    }
}
