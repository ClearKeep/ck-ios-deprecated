//
//  JoinServerView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/27/21.
//

import SwiftUI

struct JoinServerView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 4)
                
                HStack {
                    Text("Join Server")
                        .font(AppTheme.fonts.displaySmallBold.font)
                        .foregroundColor(AppTheme.colors.black.color)
                    Spacer()
                    Button(action: {}, label: {
                        Image("Hamburger")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36, alignment: .center)
                    })
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text("To be implemented")
                    Spacer()
                }
                Spacer()
            }
            .padding()
        })
    }
}

struct JoinServerView_Previews: PreviewProvider {
    static var previews: some View {
        JoinServerView()
    }
}
