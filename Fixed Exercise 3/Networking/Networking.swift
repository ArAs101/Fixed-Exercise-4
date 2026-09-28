//
//  Networking.swift
//  Fixed Exercise 3
//
//  Created by Armin Assadzadeh on 21.09.26.
//

import Foundation

final class Networking {
    private let session = URLSession(configuration: .default)
    
    func login(email: String, password: String, completionHandler: @escaping (User?, NetworkingError?) -> Void) {
        let apiKey = "AIzaSyDeLs8S6Hpy642JUPC3Pft-xVx8Ocs-uXY"
        let url = URL(
            string: "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(apiKey)"
        )!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ]
        
        func complete(user: User?, error: NetworkingError?) {
            DispatchQueue.main.async {
                completionHandler(user, error)
            }
        }
        
        do {
            request.httpBody = try JSONSerialization.data(
                withJSONObject: body,
                options: []
            )
        } catch {
            complete(user: nil, error: .serializationError)
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error as NSError? {
                if error.code == NSURLErrorNotConnectedToInternet {
                    complete(user: nil, error: .networkOffline(error.localizedDescription))
                } else {
                    complete(user: nil, error: .unexpectedError(error.localizedDescription))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                complete(user: nil, error: .unexpectedResponseFormat)
                return
            }
            
            guard let data = data else {
                complete(user: nil, error: .unexpectedResponseFormat)
                return
            }
            
            print("Status code: \(httpResponse.statusCode)")
            
            if let dataString = String(data: data, encoding: .utf8) {
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    complete(user: user, error: nil)
                } catch {
                    complete(user: nil, error: .unexpectedResponseFormat)
                }
                return
            }
            
            do {
                let responseError = try JSONDecoder().decode(
                    ResponseError.self,
                    from: data
                )
                switch responseError.error.message {
                case "INVALID_EMAIL":
                    complete(user: nil, error: .invalidEmail)
                    
                case "EMAIL_NOT_FOUND":
                    complete(user: nil, error: .wrongEmail)
                    
                case "INVALID_PASSWORD":
                    complete(user: nil, error: .wrongPassword)
                    
                case "INVALID_LOGIN_CREDENTIALS":
                    complete(user: nil, error: .invalidCredentials)
                    
                default:
                    complete(user: nil, error: .unsuccessfulStatusCode(httpResponse.statusCode))
                }
            } catch {
                complete(user: nil, error: .unsuccessfulStatusCode(httpResponse.statusCode))
            }
        }
        
        task.resume()
    }
    
    func loadCountries(
        loggedInUser: User,
        completionHandler: @escaping ([Country]?, NetworkingError?) -> Void
    ) {
        let url = URL(
            string: "https://firestore.googleapis.com/v1/projects/mad-fe/databases/(default)/documents/countries?pageSize=1000&orderBy=name"
        )!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(loggedInUser.idToken)",
            forHTTPHeaderField: "Authorization"
        )

        func complete(
            countries: [Country]?,
            error: NetworkingError?
        ) {
            DispatchQueue.main.async {
                completionHandler(countries, error)
            }
        }

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error as NSError? {
                if error.code == NSURLErrorNotConnectedToInternet {
                    complete(
                        countries: nil,
                        error: .networkOffline(error.localizedDescription)
                    )
                } else {
                    complete(
                        countries: nil,
                        error: .unexpectedError(error.localizedDescription)
                    )
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                complete(countries: nil, error: .unexpectedResponseFormat)
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if let responseError = try? JSONDecoder().decode(
                    FirestoreErrorResponse.self,
                    from: data
                ) {
                    complete(
                        countries: nil,
                        error: .unexpectedError(
                            "HTTP \(httpResponse.statusCode): \(responseError.error.message)"
                        )
                    )
                } else {
                    complete(
                        countries: nil,
                        error: .unsuccessfulStatusCode(httpResponse.statusCode)
                    )
                }
                return
            }

            let decoder = JSONDecoder()

            decoder.dateDecodingStrategy = .custom { dateDecoder in
                let container = try dateDecoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [
                    .withInternetDateTime,
                    .withFractionalSeconds
                ]

                if let date = formatter.date(from: dateString) {
                    return date
                }

                // Auch Zeitstempel ohne Sekundenbruchteile akzeptieren.
                formatter.formatOptions = [.withInternetDateTime]

                if let date = formatter.date(from: dateString) {
                    return date
                }

                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date: \(dateString)"
                )
            }

            do {
                let container = try decoder.decode(
                    DocumentsContainer.self,
                    from: data
                )

                complete(countries: container.documents, error: nil)
            } catch {
                print("Countries decoding failed: \(error)")
                complete(countries: nil, error: .unexpectedResponseFormat)
            }
        }

        task.resume()
    }}
