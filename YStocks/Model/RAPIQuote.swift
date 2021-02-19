/////
////  RAPIQuote.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

struct RAPIQuote {
    let language: String
    let region: String
    let quoteType: QuoteType
    let triggerable: Bool
    let quoteSourceName: String
    let fullExchangeName: String
    let sourceInterval: Int
    let regularMarketPreviousClose: Double
    let longName: String?
    let priceHint: Int?
    let regularMarketChangePercent: Double
    let esgPopulated: Bool
    let tradeable: Bool
    let shortName: String
    let market: String
    let exchange: String
    let marketState: MarketState
    let gmtOffSetMilliseconds: Int
    let exchangeTimezoneName: String
    let exchangeTimezoneShortName: String
    let exchangeDataDelayedBy: Int
    let regularMarketPrice: Double
    let regularMarketTime: Int
    let regularMarketChange: Double
    let symbol: String
    let contractSymbol: Bool?
    let headSymbolAsString: String?


    enum MarketState {
        case postpost
        case pre
        case regular
    }

    enum QuoteType {
        case cryptocurrency
        case equity
        case future
    }
}

