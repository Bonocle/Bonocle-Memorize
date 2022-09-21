//
//  TableNamesModel.swift
//  BonocleKit
//
//  Created by Andrew Fakher on 21/04/2022.
//

import Foundation
public struct TableNamesModel: Codable {
    public let languages: [String]
    public let tables: [Table]
}

// MARK: - Table
public struct Table: Codable {
    public let data: [TableLanguages]
}

// MARK: - TableLanguages
public struct TableLanguages: Codable {
    public let table, tableName: String
    public let code: Int
}
