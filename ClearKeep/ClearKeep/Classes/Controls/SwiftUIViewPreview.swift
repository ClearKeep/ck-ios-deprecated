//
//  SwiftUIViewPreview.swift
//  ClearKeep
//
//  Created by Luong Minh Hiep on 4/14/21.
//

import SwiftUI

struct SwiftUIViewPreview: View {
    @State private var text1 = ""
    @State private var text2 = ""
    @State private var text3 = ""
    @State private var text4 = ""
    //@State private var errorMessage = "@State private var errorMessage = some text here"
    @State private var errorMessage1 = ""
    @State private var errorMessage2 = ""
    @State private var errorMessage3 = ""
    @State private var errorMessage4 = "This field should not be empty"

    var body: some View {
        VStack(spacing: 20) {
            CustomTextFieldWithLeftIcon("Input", leftIconName: "Mail", text: $text1, errorMessage: $errorMessage1) { (changed) in
                print("\(changed)")
                errorMessage1 = text1.isEmpty ? "This field should not be empty" : ""
            }

        }
        .embededInCardView()
        .padding()
        .grandientBackground()
        //.background(Color.white)
    }
}

struct SwiftUIViewPreview_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIViewPreview()
    }
}


