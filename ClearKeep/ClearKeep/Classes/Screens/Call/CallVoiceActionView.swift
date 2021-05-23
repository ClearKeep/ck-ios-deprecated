//
//  CallVoiceActionView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 18/05/2021.
//

import SwiftUI

struct CallVoiceActionView: View {
    @ObservedObject var viewModel: CallViewModel

    var body: some View {
        GeometryReader { reader in
            VStack {
                Spacer()

                VStack {
                    HStack(spacing: 16) {
                        Spacer()
                        CallActionButtonView(onIcon: "Microphone",
                                             offIcon: "Microphone-off",
                                             isOn: viewModel.microEnable,
                                             title: "Mute",
                                             styleButton: .voice,
                                             action: viewModel.microChange)
                        Spacer()
                        CallActionButtonView(onIcon: "Video",
                                             offIcon: "Video",
                                             isOn: viewModel.cameraOn,
                                             title: "Facetime",
                                             styleButton: .voice,
                                             action: viewModel.updateCallTypeVideo)
                        Spacer()
                        CallActionButtonView(onIcon: "Speaker",
                                             offIcon: "Speaker",
                                             isOn: viewModel.speakerEnable,
                                             title: "Speaker",
                                             styleButton: .voice,
                                             action: viewModel.speakerChange)
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        CallActionButtonView(onIcon: "Phone-off",
                                             offIcon: "Phone-off",
                                             isOn: true,
                                             title: "End Call",
                                             styleButton: .endCall,
                                             action: { viewModel.endCall() })
                        Spacer()
                    }
                    .padding(.top, 115)
                }
                .frame(width: reader.size.width)
                .padding(.vertical, 16)
                .padding(.bottom, 48)
            }
        }
        .background(Color.clear)
    }
}

struct CallVoiceActionView_Previews: PreviewProvider {
    static var previews: some View {
        CallVoiceActionView(viewModel: CallViewModel())
            .background(Color.blue)
    }
}
