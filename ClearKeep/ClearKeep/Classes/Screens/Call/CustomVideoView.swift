//
//  CustomVideoView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 25/05/2021.
//

import SwiftUI
import WebRTC

class CustomVideoViewModel: ObservableObject {
    @Published var cameraOn = true
    @Published var microEnable = true
    @Published var showOptionView = false
    
    let avatarImage: Image? = nil
    let userName: String = "Alex"
    
    private var timeoutTimer: Timer?
    func triggerOptionDisplayTimeout() {
        showOptionView.toggle()
        
        if let timer = timeoutTimer {
            timer.invalidate()
            timeoutTimer = nil
        }
        
        timeoutTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(showOptionViewTimeout), userInfo: nil, repeats: false)
        RunLoop.current.add(timeoutTimer!, forMode: .default)
    }
    
    @objc private func showOptionViewTimeout() {
        showOptionView.toggle()
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
}

struct CustomVideoView: View {
    @ObservedObject var viewModel = CustomVideoViewModel()
    
    let rtcVideoView: RTCMTLEAGLVideoView
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                VideoView(rtcVideoView: rtcVideoView)
                    .blur(radius: viewModel.showOptionView ? 70 : 0)
                
//                Image("ic_app")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: reader.size.width, height: reader.size.height)
//                    .blur(radius: 70)
                
                if viewModel.showOptionView {
                    Group {
                        if viewModel.microEnable {
                            VStack {
                                CallActionButtonView(onIcon: "Microphone",
                                                     offIcon: "Microphone",
                                                     isOn: true,
                                                     title: "",
                                                     styleButton: .video,
                                                     action: { })
                                
                                Text("Tap to mute")
                                    .font(AppTheme.fonts.textXSmall.font)
                                    .foregroundColor(AppTheme.colors.gray4.color)
                                    .padding(.bottom, 24)
                            }
                        } else {
                            VStack {
                                CallActionButtonView(onIcon: "Microphone-off",
                                                     offIcon: "Microphone-off",
                                                     isOn: true,
                                                     title: "",
                                                     styleButton: .endCall,
                                                     action: {
                                                        viewModel.microEnable.toggle()
                                                     })
                                
                                Text("Microphone off")
                                    .font(AppTheme.fonts.textXSmall.font)
                                    .foregroundColor(AppTheme.colors.gray4.color)
                                    .padding(.bottom, 24)
                            }
                        }
                    }
                } else if !viewModel.microEnable {
                    VStack {
                        Spacer()
                        HStack {
                            CallActionButtonView(onIcon: "Microphone-off",
                                                 offIcon: "Microphone-off",
                                                 isOn: true,
                                                 title: "",
                                                 styleButton: .endCall,
                                                 action: {
                                                    viewModel.microEnable.toggle()
                                                 })
                                .padding(.all, 2)
                            Spacer()
                        }
                    }
                    .opacity(0.64)
                }
                
                VStack(alignment: .center) {
                    Spacer()
                    Text(viewModel.userName)
                        .font(AppTheme.fonts.displaySmallBold.font)
                        .foregroundColor(AppTheme.colors.offWhite.color)
                        .padding(.bottom, 24)
                }
            }
            .clipShape(Rectangle())
            .onTapGesture {
                viewModel.triggerOptionDisplayTimeout()
            }
        }
    }
    
    
    func getFrame(lstVideo: [RTCMTLEAGLVideoView], containerHeight: CGFloat) -> CGSize {
        let indexInTheListList = lstVideo.firstIndex(of: self.rtcVideoView) ?? -1
        var width = UIScreen.main.bounds.size.width / 2
        
        // The first item has full width
        if indexInTheListList == 0 && lstVideo.count % 2 == 1 {
            width = UIScreen.main.bounds.size.width
            print("#TEST getFrame(lstVideo:) lstVideo.count = \(lstVideo.count), indexInTheListList = \(indexInTheListList), width = \(width)")
        }
        
        // If there no more than 2 videos on screen only
        if lstVideo.count <= 2 {
            width = UIScreen.main.bounds.size.width
            print("#TEST getFrame(lstVideo:) lstVideo.count = \(lstVideo.count), width = \(width)")
        }
        
        let height = containerHeight
        switch lstVideo.count {
        case 1:
            return CGSize(width: width, height: height)
        case 2, 3, 4:
            return CGSize(width: width, height: height / 2)
        case 5, 6:
            return CGSize(width: width, height: height / 3)
        case 7, 8:
            return CGSize(width: width, height: height / 4)
        // When number of videos more than 8: allow to scroll
        case let num where num > 8:
            let heightAverage = height / CGFloat(4.2)
            return CGSize(width: width, height: heightAverage)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
 
}

//struct CustomVideoView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomVideoView()
//    }
//}
