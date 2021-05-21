//
//  VideoContainerView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 19/05/2021.
//

import SwiftUI

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
                        
                        VStack {
                            Spacer()
                            HStack(alignment: .top) {
                                Spacer()
                                VideoView(rtcVideoView: videoView)
                                    .frame(width: widthOfContainerView,
                                           height: heightOfContainerView,
                                           alignment: .center)
                                    .clipShape(Rectangle())
                                    .cornerRadius(10)
                                    .padding(.trailing, 16)
                                    .padding(.bottom, 68)
                                    .animation(.easeInOut(duration: 0.6))
                            }
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

struct VideoContainerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoContainerView(viewModel: CallViewModel())
    }
}
