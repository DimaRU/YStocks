/////
////  RapidAPIReply.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation

struct RapidAPIReply: Codable {
    let finance: Finance

    struct Finance: Codable {
        let result: [Result]?
        let error: String?
    }

    struct Result: Codable {
        let count: Int
        let quotes: [RAPIQuote]
        let jobTimestamp: Date
        let startInterval: Int
    }
}
