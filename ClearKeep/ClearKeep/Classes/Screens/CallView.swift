
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
                        if (viewModel.callStatus == .answered) { Spacer() }
                        VideoView(rtcVideoView: videoView)
                            .frame(width: viewModel.callStatus == .answered ? 120 : reader.frame(in: .global).width,
                                   height: viewModel.callStatus == .answered ? 180 : reader.size.height)
                            .clipShape(Rectangle())
                            .cornerRadius(viewModel.callStatus == .answered ? 15 : 0)
                            .animation(.easeInOut(duration: 0.6))
                    }
//                    .padding(.top, viewModel.callStatus == .answered ? 45 : 0)
//                    .edgesIgnoringSafeArea(.all)
//                    .padding(.horizontal)
                }

//                // Info call
                if viewModel.callStatus != .answered {
                    VStack(alignment: .center) {
                        Spacer(minLength: 50)
                        // Receive avatar
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding()

                        // Receive name
                        Text(viewModel.getUserName())
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)

                        // Call status
                        Text(viewModel.getStatusMessage())
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
                            Button(action: {
                                viewModel.cameraChange()
                            }, label: {
                                Image(systemName: viewModel.cameraOn ? "video.fill" : "video.slash.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(viewModel.cameraOn ? Color.white: Color.black)
                                    .padding()
                                    .background(Color.white.opacity(viewModel.cameraOn ? 0.2 : 1))
                                    .clipShape(Circle())
                            })
                            // Button speaker
                            Button(action: {
                                viewModel.speakerChange()
                            }, label: {
                                Image(systemName: !viewModel.speakerEnable ? "speaker.1.fill" : "speaker.2.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(viewModel.cameraOn ? Color.white: Color.black)
                                    .padding()
                                    .background(Color.white.opacity(viewModel.cameraOn ? 0.2 : 1))
                                    .clipShape(Circle())
                            })
                            Spacer()
                            // button swipe camera
                            Button(action: {
                                viewModel.cameraSwipeChange()
                            }, label: {
                                Image(systemName: "camera.rotate.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.white)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            })
                            Spacer()
                            // button micro
                            Button(action: {
                                viewModel.microChange()
                            }, label: {
                                Image(systemName: viewModel.microEnable ? "mic.fill": "mic.slash.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(viewModel.microEnable ? Color.white: Color.black)
                                    .padding()
                                    .background(Color.white.opacity(viewModel.microEnable ? 0.2 : 1))
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
//                .edgesIgnoringSafeArea(.all)
            }
            .background(Color.black.opacity(0.3))
//            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear(perform: {
                if let callBox = CallManager.shared.calls.first {
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
