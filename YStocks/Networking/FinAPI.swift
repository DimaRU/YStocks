/////
////  FinAPI.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import Moya

typealias MoyaResult = Result<Moya.Response, Moya.MoyaError>

enum FinAPI: TargetType {
    case stockSymbol(exchange: String)
    case trending
    case ytrending
    case profile(symbol: String)


    var baseURL: URL {
        switch self {
        case .stockSymbol,
             .profile:  return URL(string: "https://finnhub.io/api/v1")!
        case .trending    : return URL(string: "https://mboum.com/api/v1")!
        case .ytrending   : return URL(string: "https://apidojo-yahoo-finance-v1.p.rapidapi.com")!
        }
    }

    var path: String {
        switch self {
        case .stockSymbol : return "/stock/symbol"
        case .trending    : return "/tr/trending"
        case .ytrending   : return "/market/get-trending-tickers"
        case .profile     : return "/quote"
        }
    }

    var method: Moya.Method {
        switch self {
        case .stockSymbol,
             .trending,
             .ytrending,
             .profile: return .get
        }
    }

    var task: Task {
        var parameters: [String : Any] = [:]

        switch self {
        case .stockSymbol(exchange: let exchange):
            parameters["exchange"] = exchange
            return .requestParameters(parameters: parameters, encoding: Self.urlEncoding)
        case .trending:
            return .requestPlain
        case .ytrending:
            return .requestPlain
        case .profile(symbol: let symbol):
            parameters["symbol"] = symbol
            return .requestParameters(parameters: parameters, encoding: Self.urlEncoding)
        }
    }

    var headers: [String : String]? {
        var basic: [String: String] = [
            "Accept"       : "application/json",
            "Content-Type" : "application/json",
            "User-Agent"   : "YStocks"
        ]
        switch self {
        case .stockSymbol,
             .profile:
            basic["X-Finnhub-Token"] = "c0lvbdn48v6p8fvivtd0"
        case .trending:
            basic["X-Mboum-Secret"] = "6lZCEjA3mhxCNpIQw29jVB2tbZcEjzu1arvaXpcXoXKxwOVR2Tw2qEgzPpqL"
        case .ytrending:
            basic["x-rapidapi-key"] = "7e750ee882msh4216d6cbc539cbcp178008jsne1a9f542fadc"
            basic["x-rapidapi-host"] = "apidojo-yahoo-finance-v1.p.rapidapi.com"
        }
        return basic
    }

    static let urlEncoding = URLEncoding(destination: .methodDependent, arrayEncoding: .noBrackets, boolEncoding: .literal)

    var sampleData: Data {
        return Data()
    }

}
