/////
////  Profile.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation

struct SymbolProfile: Codable {
    let country: String
    let currency: String
    let exchange: String
    let finnhubIndustry: String
    let ipo: String
    let logo: String
    let marketCapitalization: Int
    let name: String
    let phone: String
    let shareOutstanding: Double
    let ticker: String
    let weburl: String
}