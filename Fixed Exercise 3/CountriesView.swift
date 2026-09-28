//
//  CountriesView.swift
//  Fixed Exercise 4
//
//  Created by Armin Assadzadeh on 28.09.26.
//


import SwiftUI

struct CountriesView: View {
    let networking: Networking
    let loggedInUser: User

    @State private var countries: [Country]?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading countries...")
            } else if let errorMessage = errorMessage {
                VStack(spacing: 16) {
                    Text("Countries could not be loaded")
                        .font(.headline)

                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Try again") {
                        loadCountries()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if let countries = countries {
                if countries.isEmpty {
                    Text("No countries available.")
                        .foregroundStyle(.secondary)
                } else {
                    List(countries, id: \.ID) { country in
                        NavigationLink {
                            CountryDetailView(country: country)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(country.name)
                                    .font(.headline)

                                Text(country.capital)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Countries")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .onAppear {
            if countries == nil && errorMessage == nil {
                loadCountries()
            }
        }
    }

    private func loadCountries() {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        networking.loadCountries(loggedInUser: loggedInUser) {
            loadedCountries, error in
            
            isLoading = false

            if let loadedCountries = loadedCountries {
                countries = loadedCountries
                return
            }

            guard let error = error else {
                errorMessage = "No data was returned."
                return
            }

            switch error {
            case .networkOffline(let message),
                 .unexpectedError(let message):
                errorMessage = message

            case .unexpectedResponseFormat:
                errorMessage = "The server returned data in an unexpected format."

            case .unsuccessfulStatusCode(let statusCode):
                errorMessage = "The server returned HTTP \(statusCode)."

            default:
                errorMessage = "The countries could not be loaded."
            }
        }
    }
}
