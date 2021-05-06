//
//  PassCodeInputField.swift
//  PassCodeInputDemo
//
//  Created by Dev Mukherjee on 4/5/20.
//  Copyright © 2020 Anomaly Software. All rights reserved.
//

import SwiftUI
import Foundation

struct PassCodeInputField: View {
    
    @ObservedObject var inputModel: PassCodeInputModel
    
    var body: some View {
        HStack(spacing: 24) {
            Spacer()
            ForEach(0 ..< self.inputModel.numberOfCells) { index in
                PassCodeInputCell(index: index, selectedCellIndex: self.$inputModel.selectedCellIndex, textReference: self.$inputModel.passCode[index])
                    .frame(width: 56, height: 56, alignment: .center)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            Spacer()
        }
    }
}

struct PassCodeInputField_Previews: PreviewProvider {
    static var previews: some View {
        PassCodeInputField(inputModel: PassCodeInputModel(passCodeLength: 6))
    }
}
