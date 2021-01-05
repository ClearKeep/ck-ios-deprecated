//
//  ShapeCustom.swift
//  ClearKeep
//
//  Created by VietAnh on 1/4/21.
//

import Foundation
import SwiftUI

struct RoundedTopShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 25, height: 25))
        return Path(path.cgPath)
    }
}
