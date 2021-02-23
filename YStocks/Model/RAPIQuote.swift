/////
////  RAPIQuote.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation

struct RAPIQuote: Codable {
    let language: String
    let region: String
    let quoteType: String
    let triggerable: Bool
    let quoteSourceName: String
    let fullExchangeName: String
    let sourceInterval: Int
    let longName: String?
    let priceHint: Int?
    let esgPopulated: Bool
    let tradeable: Bool
    let shortName: String
    let market: String
    let exchange: String
    let marketState: MarketState
    let gmtOffSetMilliseconds: Int
    let exchangeTimezoneName: String
    let exchangeTimezoneShortName: String
    let exchangeDataDelayedBy: Date
    let regularMarketPreviousClose: Float
    let regularMarketPrice: Float
    let regularMarketChangePercent: Float
    let regularMarketChange: Float
    let regularMarketTime: Date
    let symbol: String
    let contractSymbol: Bool?
    let headSymbolAsString: String?

    enum MarketState: String, Codable {
        case postpost = "POSTPOST"
        case pre = "PRE"
        case regular = "REGULAR"
        case closed = "CLOSED"
    }
}
