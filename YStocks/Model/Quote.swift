/////
////  Quote.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation

struct Quote: Codable {
    let currentPrice: Float
    let highPrice: Float
    let lowPrice: Float
    let openPrice: Float
    let previousClosePrice: Float
    let timeStamp: Date

    enum CodingKeys: String, CodingKey {
        case currentPrice = "c"
        case highPrice = "h"
        case lowPrice = "l"
        case openPrice = "o"
        case previousClosePrice = "pc"
        case timeStamp = "t"
    }
}
