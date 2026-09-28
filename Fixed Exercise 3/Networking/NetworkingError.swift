//
//  NetworkingError.swift
//  Fixed Exercise 3
//
//  Created by Armin Assadzadeh on 22.09.26.
//

import Foundation

enum NetworkingError: Error {
    case serializationError
    case invalidEmail
    case wrongEmail
    case wrongPassword
    case invalidCredentials
    case networkOffline(String)
    case unexpectedResponseFormat
    case unsuccessfulStatusCode(Int)
    case unexpectedError(String)
}
