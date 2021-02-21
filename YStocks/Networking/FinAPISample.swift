/////
////  FinAPISample.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import Moya

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
            return loadSampleData(name: "stockSymbol_\(exchange)") ?? Data()
        case .trending:
            return loadSampleData(name: "trending") ?? Data()
        case .ytrending:
            return loadSampleData(name: "ytrending") ?? Data()
        case .profile(symbol: let symbol):
            guard
                let sampleArray: [SymbolProfile] = loadSample(type: [SymbolProfile].self, name: "symbolProfile"),
                let sample = sampleArray.first(where: { $0.ticker == symbol })
            else { return Data() }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .secondsSince1970
            let data = try? encoder.encode(sample)
            return data ?? Data()
        }
    }

}
