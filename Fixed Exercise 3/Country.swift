//
//  Country.swift
//  Fixed Exercise 4
//
//  Created by Armin Assadzadeh on 28.09.26.
//


import Foundation

struct Country: Decodable {
    var ID: String
    var name: String
    var currency: String
    var capital: String
    var native: String
    var continent: String
    var phone: String
    var createTime: Date
    var updateTime: Date
    var languages: [String]

    private enum RootCodingKeys: String, CodingKey {
        case ID = "name"
        case createTime
        case updateTime
        case fields
    }

    private enum NestedCodingKeys: String, CodingKey {
        case name
        case currency
        case capital
        case native
        case continent
        case phone
        case languages
    }

    private enum StringValueCodingKeys: String, CodingKey {
        case stringValue
    }

    private enum ArrayValueCodingKeys: String, CodingKey {
        case arrayValue
    }

    private enum ArrayValueNestedCodingKeys: String, CodingKey {
        case values
    }

    init(from decoder: Decoder) throws {
        // Oberste Ebene eines Länder-Dokuments
        let rootContainer = try decoder.container(
            keyedBy: RootCodingKeys.self
        )

        let documentPath = try rootContainer.decode(
            String.self,
            forKey: .ID
        )

        ID = (documentPath as NSString).lastPathComponent

        createTime = try rootContainer.decode(
            Date.self,
            forKey: .createTime
        )

        updateTime = try rootContainer.decode(
            Date.self,
            forKey: .updateTime
        )

        // Das Objekt unter "fields"
        let fieldsContainer = try rootContainer.nestedContainer(
            keyedBy: NestedCodingKeys.self,
            forKey: .fields
        )

        // Alle Textfelder haben dieselbe innere Struktur.
        func decodeString(forKey key: NestedCodingKeys) throws -> String {
            let valueContainer = try fieldsContainer.nestedContainer(
                keyedBy: StringValueCodingKeys.self,
                forKey: key
            )

            return try valueContainer.decode(
                String.self,
                forKey: .stringValue
            )
        }

        name = try decodeString(forKey: .name)
        currency = try decodeString(forKey: .currency)
        capital = try decodeString(forKey: .capital)
        native = try decodeString(forKey: .native)
        continent = try decodeString(forKey: .continent)
        phone = try decodeString(forKey: .phone)

        // fields → languages → arrayValue → values
        let languagesContainer = try fieldsContainer.nestedContainer(
            keyedBy: ArrayValueCodingKeys.self,
            forKey: .languages
        )

        let arrayContainer = try languagesContainer.nestedContainer(
            keyedBy: ArrayValueNestedCodingKeys.self,
            forKey: .arrayValue
        )

        languages = []

        // Ein leeres Array kann ohne "values" dargestellt sein.
        if arrayContainer.contains(.values) {
            var valuesContainer = try arrayContainer.nestedUnkeyedContainer(
                forKey: .values
            )

            while !valuesContainer.isAtEnd {
                let languageContainer = try valuesContainer.nestedContainer(
                    keyedBy: StringValueCodingKeys.self
                )

                let language = try languageContainer.decode(
                    String.self,
                    forKey: .stringValue
                )

                languages.append(language)
            }
        }
    }
}