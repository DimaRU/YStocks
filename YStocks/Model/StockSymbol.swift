/////
////  StockSymbol.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

struct StockSymbol: Codable {
    let currency: String
    let stockSymbolDescription: String
    let displaySymbol: String
    let figi: String
    let mic: MarketIdentifierCode
    let symbol: String
    let type: StockType
}
