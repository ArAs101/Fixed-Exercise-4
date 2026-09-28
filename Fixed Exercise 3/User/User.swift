//
//  User.swift
//  Fixed Exercise 3
//
//  Created by Armin Assadzadeh on 21.09.26.
//

import Foundation

struct User: Codable {
    let localId: String
    let email: String
    let displayName: String
    let idToken: String
    let registered: Bool
    let refreshToken: String
}
