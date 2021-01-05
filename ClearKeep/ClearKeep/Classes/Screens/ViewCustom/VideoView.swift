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
struct VideoView: UIViewRepresentable {
    let rtcVideoView: RTCMTLVideoView

    func makeUIView(context: Context) -> RTCMTLVideoView {
        rtcVideoView.videoContentMode = .scaleAspectFit
        return rtcVideoView
    }

    func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {
    }
}
#else
struct VideoView: UIViewRepresentable {
    let rtcVideoView: RTCEAGLVideoView

    func makeUIView(context: Context) -> RTCEAGLVideoView {
        return rtcVideoView
    }

    func updateUIView(_ videoView: RTCEAGLVideoView, context: Context) {
    }
}
#endif
