//
//  LoginView.swift
//  Fixed Exercise 4
//
//  Created by Armin Assadzadeh on 28.09.26.
//

// xcode: set sdk=iOS

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var loggedInUser: User?
    @State private var showCountries = false
    let networking: Networking
    
    private enum Field {
        case email
        case password
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 16) {
                Text("Email")
                TextField("yourname@example.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
                
                Text("Password")
                SecureField("Your password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        login()
                    }
                
                HStack {
                    Spacer()
                    Button("Login") {
                        login()
                    }
                    Spacer()
                }
                
                // Answer to the question asked in the instructions: The keyboard may overlap with one of the input fields when the iPhone is in Landscape Mode, which can irritate the user and worsen the User Experience as they won't be able to check their input for typos. In the context of this submission, the usage of HStack and VStack avoids this inconvenience.
                
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Logging in...")
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: 500)
            .padding()
            .disabled(isLoading)
            Spacer()
        }
        
        .toolbar(.hidden, for: .navigationBar)
        .background {
            NavigationLink(
                destination: Group {
                    if let loggedInUser = loggedInUser {
                        CountriesView(
                            networking: networking,
                            loggedInUser: loggedInUser
                        )
                    }
                },
                isActive: $showCountries,
                label: {
                    EmptyView()
                }
            )
        }
        .onAppear {
            loggedInUser = nil
        }
        
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func login() {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertTitle = "Missing Email"
            alertMessage = "Please enter your email address."
            showAlert = true
            return
        }
        
        guard !password.isEmpty else {
            alertTitle = "Missing Password"
            alertMessage = "Please enter your password."
            showAlert = true
            return
        }
        
        focusedField = nil
        isLoading = true
        
        networking.login(email: email, password: password) { user, error in
            isLoading = false
            
            if let user = user {
                loggedInUser = user
                password = ""
                showCountries = true
                return
            }
            
            if let error = error {
                handleNetworkingError(error)
            }
        }
    }
    
    func handleNetworkingError(_ error: NetworkingError) {
        alertTitle = "Login Failed"
        switch error {
        case .serializationError:
            alertMessage = "The login request could not be created."

        case .invalidEmail:
            alertMessage = "Please enter a valid email address."

        case .wrongEmail:
            alertMessage = "The email address is incorrect."

        case .wrongPassword:
            alertMessage = "The password is incorrect."

        case .invalidCredentials:
            alertMessage = "The email address or password is incorrect."

        case .networkOffline(let message):
            alertMessage = message

        case .unexpectedResponseFormat:
            alertMessage = "The server returned an unexpected response."

        case .unsuccessfulStatusCode(let statusCode):
            alertMessage = "The server returned an error (HTTP \(statusCode))."

        case .unexpectedError(let message):
            alertMessage = message
        }

        showAlert = true
    }
}

#Preview {
    NavigationStack {
        LoginView(networking: Networking())
    }
}
