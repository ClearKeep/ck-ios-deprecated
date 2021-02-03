//
//  ErrorResponse.swift
//  ClearKeep
//
//  Created by Seoul on 2/1/21.
//

import Foundation

struct ErrorResponse: Decodable {
    let code: Int
    let message: String
}

struct Customer: Decodable {
    let errors: [ErrorResponse]
}
