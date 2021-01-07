
import SwiftUI

struct CallView: View {
    //    @Binding var isShowCall: Bool
    @ObservedObject var viewModel = CallViewModel()
    
    var body: some View {
        GeometryReader{ reader in
            ZStack(alignment: .top) {
                // remotes video
                if viewModel.callGroup {
                    // show short
                    VStack {
                        GridView(columns: 3, list: viewModel.remotesVideoView) { videoView in
                            VideoView(rtcVideoView: videoView)
                                .frame(width: 120, height: 150)
                                .clipShape(Capsule())
                        }
                        .padding([.horizontal, .bottom])
                        Spacer()
                    }
                } else if let videoView = viewModel.remoteVideoView {
                    // show full screen
                    VideoView(rtcVideoView: videoView)
                }
                
                // local video
                if let videoView = viewModel.localVideoView {
                    HStack(alignment: .top) {
                        Spacer()
                        VideoView(rtcVideoView: videoView)
                            .frame(width: 120,
                                   height: 180)
//                            .animation(.easeInOut(duration: 0.6))
                            .clipShape(Rectangle())
                            .cornerRadius(15)
                    }.padding(.top, 45)
                    .padding(.horizontal)
                }
                
                // Info call
                if viewModel.receiveCameraOff ||
                    viewModel.callStatus == .calling ||
                    viewModel.callStatus == .ringing {
                    VStack(alignment: .center) {
                        Spacer(minLength: 50)
                        // Receive avatar
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                            .foregroundColor(Color.white)
                            .padding()
                        
                        // Receive name
                        Text("Phan Van Dai")
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                        
                        // Call status
                        Text("Đang đổ chuông...")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                }
                
                // action on view bottom
                VStack {
                    Spacer()
                    VStack {
                        Color.white.opacity(0.5)
                            .frame(width: 45, height: 8)
                            .clipShape(Capsule())
                            .padding(.top, 5)
                        
                        HStack {
                            Spacer()
                            // Button camera
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Image(systemName: "video.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.white)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            })
                            Spacer()
                            // button swipe camera
                            Button(action: {}, label: {
                                Image(systemName: "camera.rotate.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.white)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            })
                            Spacer()
                            // button micro
                            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.white)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            })
                            Spacer()
                            // button end call
                            Button(action: {
                                viewModel.endCall()
                                //                            isShowCall = false
                            }, label: {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.white)
                                    .padding()
                                    .background(Color.red)
                                    .clipShape(Circle())
                            })
                            Spacer()
                        }
                        .padding(.bottom, 14)
                        .padding(.top, 5)
                    }
                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
                    .background(Color.black.opacity(0.85))
                    .clipShape(RoundedTopShape())
                }
                .edgesIgnoringSafeArea(.all)
            }
            .background(Color.black.opacity(0.3))
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear(perform: {
                print("onAppear video View")
                if let callBox = CallManager.shared.calls.first {
                    print("onAppear video View update")
                    viewModel.updateCallBox(callBox: callBox)
                }
            })
        }
    }
}

struct CallView_Previews: PreviewProvider {
    static var previews: some View {
        CallView()
    }
}
