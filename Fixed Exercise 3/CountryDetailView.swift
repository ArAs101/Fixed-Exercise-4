//
//  CountryDetailView.swift
//  Fixed Exercise 4
//
//  Created by Armin Assadzadeh on 28.09.26.
//


import SwiftUI

struct CountryDetailView: View {
    let country: Country

    var body: some View {
        List {
            Section("General information") {
                detailRow("Name", value: country.name)
                detailRow("Native name", value: country.native)
                detailRow("Capital", value: country.capital)
                detailRow("Continent", value: country.continent)
                detailRow("Currency", value: country.currency)
                detailRow("Calling code", value: country.phone)
            }

            Section("Languages") {
                if country.languages.isEmpty {
                    Text("No languages available")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(
                        country.languages.indices,
                        id: \.self
                    ) { index in
                        Text(country.languages[index])
                    }
                }
            }

            Section("Document information") {
                detailRow("ID", value: country.ID)

                detailRow(
                    "Created",
                    value: country.createTime.formatted(
                        date: .abbreviated,
                        time: .standard
                    )
                )

                detailRow(
                    "Updated",
                    value: country.updateTime.formatted(
                        date: .abbreviated,
                        time: .standard
                    )
                )
            }
        }
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(
        _ title: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value.isEmpty ? "Not specified" : value)
        }
        .padding(.vertical, 2)
    }
}