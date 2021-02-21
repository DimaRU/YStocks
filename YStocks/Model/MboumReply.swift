/////
////  MboumReply.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation

struct MboumReply: Codable {
    let count: Int
    let quotes: [String]
    let jobTimestamp: Date
    let startInterval: Int
}
