//
//  ResponseError.swift
//  Fixed Exercise 3
//
//  Created by Armin Assadzadeh on 22.09.26.
//

import Foundation

struct ResponseError: Codable {
    let error: FirebaseError
}

struct FirebaseError: Codable {
    let code: Int
    let message: String
    let errors: [FirebaseErrorDetail]
}

struct FirebaseErrorDetail: Codable {
    let message: String
    let domain: String
    let reason: String
}
