/////
////  StocksIndexName.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation

enum StocksIndexName: String, Codable {
    case SnP500 = "^GSPC"
    case Nasdaq100 = "^NDX"
    case DowJones = "^DJI"
}
