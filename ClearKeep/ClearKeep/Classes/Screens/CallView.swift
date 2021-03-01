
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
                    let videoViewFrame = CGRect.init(origin: CGPoint.zero, size: viewModel.getRemoteVideoRenderSize(videoView: videoView))
                    let newVideoViewFrame = viewModel.getNewVideoViewFrame(videoViewFrame: videoViewFrame, containerFrame: reader.frame(in: .global))

                    let leadingPadding = -(newVideoViewFrame.width - reader.frame(in: .global).width)/2
                    let topPadding = -(newVideoViewFrame.height - reader.frame(in: .global).height)/2
                    
                    VideoView(rtcVideoView: videoView)
                        .frame(width: newVideoViewFrame.width,
                               height: newVideoViewFrame.height,
                               alignment: .center)
                        .padding(.leading, leadingPadding)
                        .padding(.top, topPadding)
                }
                
                // local video
                if let videoView = viewModel.localVideoView {
                    if viewModel.callStatus == .answered {

                        let widthOfContainerView: CGFloat = 120.0
                        let heightOfContainerView: CGFloat = 200
                        let containerFrame = CGRect.init(x: 0, y: 0, width: widthOfContainerView, height: heightOfContainerView)
                        let newVideoViewFrame = viewModel.getNewVideoViewFrame(videoViewFrame: videoView.frame, containerFrame: containerFrame)
                        
                        let leadingPadding = -(newVideoViewFrame.width - containerFrame.width)/2
                        let topPadding = -(newVideoViewFrame.height - containerFrame.height)/2
                        
                        HStack(alignment: .top) {
                            Spacer()
                            VideoView(rtcVideoView: videoView)
                                .frame(width: newVideoViewFrame.width,
                                       height: newVideoViewFrame.height,
                                       alignment: .center)
                                .padding(.leading, leadingPadding)
                                .padding(.top, topPadding)
                                .clipShape(Rectangle())
                                .cornerRadius(15)
                                .animation(.easeInOut(duration: 0.6))
                        }
                    } else {
                        let newVideoViewFrame = viewModel.getNewVideoViewFrame(videoViewFrame: videoView.frame, containerFrame: reader.frame(in: .global))

                        VideoView(rtcVideoView: videoView)
                            .frame(width: newVideoViewFrame.width,
                                   height: newVideoViewFrame.height,
                                   alignment: .center)
                            .clipShape(Rectangle())
                            .animation(.easeInOut(duration: 0.6))
                    }
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
//                            Spacer()
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
                            Spacer()
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
//                            Spacer()
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
