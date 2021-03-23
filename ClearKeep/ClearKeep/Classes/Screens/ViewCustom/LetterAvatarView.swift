//
//  LetterAvatarView.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 3/24/21.
//

import SwiftUI

struct LetterAvatarView: View {
    let text: String
    let image: Image? 
    let textColor: UIColor = .white
    let backgroundColor: UIColor = .black
    
    init(text: String, image: Image? = nil) {
        self.text = text
        self.image = image
    }
    
    var body: some View {
        
        ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
            if let loadedImage = image {
                loadedImage
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, alignment: .center)
            } else {
                Image(systemName: "circle.fill")
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, alignment: .center)
                
                Text(text.prefixShortName())
                    .font(.system(size: 60, weight: .bold, design: .default))
                    .frame(alignment: .center)
                    .foregroundColor(.white)
            }
        }
        .clipShape(Circle())
    }
}

struct LetterAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        LetterAvatarView(text: "My Group")
    }
}
