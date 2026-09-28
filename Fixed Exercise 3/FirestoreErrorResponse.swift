//
//  FirestoreErrorResponse.swift
//  Fixed Exercise 4
//
//  Created by Armin Assadzadeh on 28.09.26.
//


import Foundation

struct FirestoreErrorResponse: Decodable {
    let error: FirestoreError
}

struct FirestoreError: Decodable {
    let code: Int
    let message: String
    let status: String?
}