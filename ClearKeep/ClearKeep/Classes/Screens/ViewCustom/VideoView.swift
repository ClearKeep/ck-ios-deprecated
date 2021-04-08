//
//  VideoView.swift
//  ClearKeep
//
//  Created by VietAnh on 1/4/21.
//

import Foundation
import SwiftUI
import WebRTC

#if arch(arm64)
typealias RTCMTLEAGLVideoView = RTCMTLVideoView
#else
typealias RTCMTLEAGLVideoView = RTCEAGLVideoView
#endif

//#if arch(arm64)
struct VideoView: UIViewRepresentable {
    let rtcVideoView: RTCMTLEAGLVideoView
    
    func makeUIView(context: Context) -> RTCMTLEAGLVideoView {
        #if arch(arm64)
        rtcVideoView.videoContentMode = .scaleAspectFill
        #else
        #endif
        return rtcVideoView
    }
    
    func updateUIView(_ uiView: RTCMTLEAGLVideoView, context: Context) {
    }
    
    func getFrame(lstVideo: [RTCMTLEAGLVideoView]) -> CGSize{
        let indexOfList = lstVideo.firstIndex(of: self.rtcVideoView) ?? 0
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        switch lstVideo.count {
        case 2:
            return CGSize(width: width, height: height / 2)
        case 4:
            return CGSize(width: width / 2, height: height / 2)
        case 5:
            if indexOfList < 4 {
                return CGSize(width: width / 2, height: height / 3)
            } else {
                return CGSize(width: width, height: height / 3)
            }
        case 6:
            return CGSize(width: width / 2, height: height / 3)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
}
//#else
//struct VideoView: UIViewRepresentable {
//    let rtcVideoView: RTCEAGLVideoView
//
//    func makeUIView(context: Context) -> RTCEAGLVideoView {
//        return rtcVideoView
//    }
//
//    func updateUIView(_ videoView: RTCEAGLVideoView, context: Context) {
//    }
//}
//#endif
