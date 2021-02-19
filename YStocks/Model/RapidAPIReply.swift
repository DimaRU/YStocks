/////
////  RapidAPIReply.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

struct RapidAPIReply {
    let finance: Finance

    struct Finance {
        let result: [Result]?
        let error: String?
    }

    struct Result {
        let count: Int
        let quotes: [RAPIQuote]
        let jobTimestamp: Int
        let startInterval: Int
    }
}
