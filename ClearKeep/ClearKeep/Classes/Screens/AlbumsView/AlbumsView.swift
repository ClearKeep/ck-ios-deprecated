//
//  AlbumsView.swift
//  ClearKeep
//
//  Created by Diflega on 9/6/21.
//

import Foundation
import SwiftUI

struct AlbumsView: View {
    
    @Binding var dismissAlert: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Test")
            Spacer()
        }
        .applyNavigationBarPlainStyleLight(title: "", leftBarItems: {
            ButtonClose {
                dismissAlert = false
            }
        }, rightBarItems: {
            Button(action: saveInfo) {
                Text("Upload")
                    .font(AppTheme.fonts.linkMedium.font)
                    .foregroundColor(AppTheme.colors.offWhite.color)
            }
        })
    }
    
    fileprivate func saveInfo() {
        
    }
}
