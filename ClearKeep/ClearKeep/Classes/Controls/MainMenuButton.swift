//
//  MainMenuButton.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/20/21.
//

import SwiftUI

struct MainMenuItemView: View {
    let isSelected: Bool
    let hasNewMessage: Bool
    let imageName: String = "ic_app_new"
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(imageName)
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 5.0))
                .padding(.all, 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0).stroke(isSelected ? AppTheme.colors.black.color : Color.clear, lineWidth: 1.0)
                )
            
            if hasNewMessage {
                AppTheme.colors.secondary.color
                    .frame(width: 8, height: 8, alignment: .center)
                    .clipShape(Circle())
                    .padding(.all, 3)
            }
        }
    }
}

struct MainMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            VStack {
                MainMenuItemView(isSelected: true, hasNewMessage: true)
                MainMenuItemView(isSelected: false, hasNewMessage: true)
                MainMenuItemView(isSelected: true, hasNewMessage: false)
                MainMenuItemView(isSelected: false, hasNewMessage: false)
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
}
