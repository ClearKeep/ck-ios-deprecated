//
//  CallActionBottomView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 18/05/2021.
//

import SwiftUI

struct CallVideoActionView: View {
    @ObservedObject var viewModel: CallViewModel

    var body: some View {
        GeometryReader { reader in
            VStack {
                Spacer()

                VStack {
                    HStack(spacing: 16) {
                        Spacer()
                        CallActionButtonView(onIcon: "Microphone", offIcon: "Microphone-off", isOn: viewModel.microEnable, action: viewModel.microChange)
                        Spacer()
                        CallActionButtonView(onIcon: "Video", offIcon: "Video", isOn: viewModel.cameraOn, action: viewModel.cameraChange)
                        Spacer()
                        CallActionButtonView(onIcon: "Camera-rotate", offIcon: "Camera-rotate", isOn: viewModel.cameraFront, action: viewModel.cameraSwipeChange)
                        Spacer()
                        CallActionButtonView(onIcon: "Phone-off", offIcon: "Phone-off", isOn: true,styleButton: .endCall , action: {
                            viewModel.endCall()
                            // isShowCall = false
                        })
                        Spacer()
                    }
                }
                .frame(width: reader.size.width)
                .padding(.vertical, 16)
                .padding(.bottom, 20)
                .background(AppTheme.colors.gray4.color)
            }
        }
        .background(Color.clear)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct CallActionBottomView_Previews: PreviewProvider {
    static var previews: some View {
        CallVideoActionView(viewModel: CallViewModel())
    }
}

