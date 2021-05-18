
import SwiftUI

struct CallView: View {
    //    @Binding var isShowCall: Bool
    @ObservedObject var viewModel = CallViewModel()
    
    var body: some View {
        GeometryReader{ reader in
            ZStack(alignment: .top) {
                
                // MARK: - Content Answer
                // avatar blur
                Image("ic_app")
                    .resizable()
                    .frame(width: reader.frame(in: .global).width, height: reader.frame(in: .global).height, alignment: .center) // TODO: Fixed ic_app
                    .blur(radius: 70)
                    
                if viewModel.callType == .video {
                    // Video Container View display
                    VideoContainerView(viewModel: viewModel)
                }
                
                // MARK: - Top View
                CallHeaderView(viewModel: viewModel)

//                // Info call
                if (viewModel.callStatus != .answered && viewModel.callType == .video) ||
                    (viewModel.callType == .audio) {
                    VStack(alignment: .center) {
                        // Receive avatar
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding()
                            .padding(.top, 120)

                        // Receive name
                        Text(viewModel.getUserName())
                            .font(.system(size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)

                        if viewModel.callType == .audio, viewModel.callStatus == .answered {
                            // show time call
                            Text(viewModel.timeCall)
                                .font(.system(size: 16))
                                .foregroundColor(Color.white)
                        } else {
                            // Call status
                            Text(viewModel.getStatusMessage())
                                .font(.system(size: 16))
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                    }
                }

                // action on view bottom
                VStack {
                    Spacer()
                    CallActionsView(viewModel: viewModel).frame(width: UIScreen.main.bounds.width)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .background(Color.black.opacity(0.3))
            .navigationBarHidden(true)
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
}

struct CallHeaderView: View {
    
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        // Top bar
        if viewModel.callStatus == .answered,
           viewModel.callType == Constants.CallType.audio {
            HStack() {
                Spacer()
                // button camera switch
                if viewModel.callType != .audio { // TODO: check requesting audio
//                    Button(action: {
//                        viewModel.isVideoRequesting = false
//                    }, label: {
//                        Image(systemName: "video.fill")
//                            .font(.system(size: 16))
//                            .foregroundColor(Color.white)
//                            .padding(8)
//                            .background(Color(.lightGray).opacity(0.7))
//                            .clipShape(Circle())
//                    })
                } else {
                    Button(action: {
                        viewModel.updateCallTypeVideo()
                    }, label: {
                        HStack {
                            Image(systemName: "video.slash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color.black)
                                .padding(5)
                                .background(Color.white)
                                .clipShape(Circle())
                                .padding(EdgeInsets(top: 2, leading: 1, bottom: 2, trailing: 0))
                            Spacer()
                        }
                        .background(Color(.lightGray).opacity(0.7))
                        .clipShape(Capsule())
                    }).frame(width: 65)
                }
            }.padding([.trailing, .top])
        }
    }
}

struct VideoContainerView: View {
    
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        GeometryReader{ reader in
            ZStack(alignment: .top) {
                // remote videos
                if viewModel.remotesVideoView.count > 1 {
                    // show short
                    VStack {
                        let columns = viewModel.remotesVideoView.count < 4 ? 1 : 2
                        GridView(columns: columns, list: viewModel.remotesVideoView) { videoView in
                            let view = VideoView(rtcVideoView: videoView)
                            let sizeView = view.getFrame(lstVideo: viewModel.remotesVideoView)
                                view
                                    .frame(width: sizeView.width, height: sizeView.height)
                                .clipShape(Rectangle())
                        }
                        Spacer()
                    }
                }
                else if let videoView = viewModel.remoteVideoView {
                    // show full screen
                    let width = reader.frame(in: .global).width
                    let height = reader.frame(in: .global).height
                    VideoView(rtcVideoView: videoView)
                        .frame(width: width,
                               height: height,
                               alignment: .center)
                        .animation(.easeInOut(duration: 0.6))
                }
                
                // local video
                if let videoView = viewModel.localVideoView , viewModel.remotesVideoView.count < 4 {
                    if viewModel.callStatus == .answered {
                        let widthOfContainerView: CGFloat = 120
                        let heightOfContainerView: CGFloat = 180

                        HStack(alignment: .top) {
                            VideoView(rtcVideoView: videoView)
                                .frame(width: widthOfContainerView,
                                       height: heightOfContainerView,
                                       alignment: .center)
                                .clipShape(Rectangle())
                                .cornerRadius(10)
                                .padding(.leading, 8)
                                .padding(.top, 8)
                                .animation(.easeInOut(duration: 0.6))
                            Spacer()
                        }
                    } else {
                        let width = reader.frame(in: .global).width
                        let height = reader.frame(in: .global).height
                        VideoView(rtcVideoView: videoView)
                            .frame(width: width,
                                   height: height,
                                   alignment: .center)
                            .clipShape(Rectangle())
                            .animation(.easeInOut(duration: 0.6))
                    }
                }
            }
        }
    }
}

struct CallActionsView: View {
    @ObservedObject var viewModel: CallViewModel

    var body: some View {
        Group {
            if viewModel.callGroup {
                GeometryReader { reader in
                    VStack {
                        Spacer()

                        VStack {
                            Color.white.opacity(0.5)
                                .frame(width: 45, height: 8)
                                .clipShape(Capsule())
                                .padding(.top, 5)
                        
                            HStack(spacing: 0) {
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
                                }).frame(width: reader.size.width * 0.2)

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
                                }).frame(width: reader.size.width * 0.2)

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
                                }).frame(width: reader.size.width * 0.2)

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
                                }).frame(width: reader.size.width * 0.2)
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
                                }).frame(width: reader.size.width * 0.2)
                            }
                            .padding(.bottom, 14)
                            .padding(.top, 5)
                        }
                        .background(Color.black.opacity(0.5))
                        .clipShape(RoundedTopShape())
                    }.background(Color.clear)
                }.background(Color.clear)
            } else {
                PeerCallView(viewModel: viewModel)
            }
        }
    }
}

//struct CallActionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        CallActionsView(viewModel: CallViewModel())
//    }
//}
//
//
//struct CallView_Previews: PreviewProvider {
//    static var previews: some View {
//        CallView()
//    }
//}
