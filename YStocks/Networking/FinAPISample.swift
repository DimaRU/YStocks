/////
////  FinAPISample.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import Moya

#if DEBUG
extension FinAPI {
    static var sampleBundle: Bundle?

    private func loadSampleData(name: String) -> Data? {
        guard
            let bundle = FinAPI.sampleBundle,
            let path = bundle.url(forResource: name, withExtension: "json")
        else { return nil }
        return try? Data(contentsOf: path)
    }

    private func loadSample<T: Decodable>(type: T.Type, name: String) -> T? {
        guard
            let bundle = FinAPI.sampleBundle,
            let path = bundle.url(forResource: name, withExtension: "json"),
            let data = try? Data(contentsOf: path)
        else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try? decoder.decode(type, from: data)
    }

    var sampleData: Data {
        switch self {
        case .stockSymbol(exchange: let exchange):
            return loadSampleData(name: "stockSymbols_\(exchange)") ?? Data()
        case .trending:
            return loadSampleData(name: "mboum-trending") ?? Data()
        case .ytrending:
            return loadSampleData(name: "ytrending-tickers") ?? Data()
        case .constituents(stockIndex: let stockIndex):
            return loadSampleData(name: "constituents_\(stockIndex.rawValue.dropFirst(1))") ?? Data()
        case .profile(symbol: let symbol):
            guard
                let sampleArray: [SymbolProfile] = loadSample(type: [SymbolProfile].self, name: "symbolProfiles"),
                let sample = sampleArray.first(where: { $0.ticker == symbol })
            else { return Data() }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            let data = try? encoder.encode(sample)
            return data ?? Data()
        case .quote(symbol: let symbol):
            guard
                let sampleArray: [SymbolProfile] = loadSample(type: [SymbolProfile].self, name: "quotes"),
                let sample = sampleArray.first(where: { $0.ticker == symbol })
            else { return Data() }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            let data = try? encoder.encode(sample)
            return data ?? Data()
        }
    }

}
#else
extension FinAPI {
    var sampleData: Data {
        Data()
    }
}
#endif
