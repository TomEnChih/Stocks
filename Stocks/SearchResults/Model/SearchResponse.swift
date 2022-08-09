//
//  SearchResponse.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/8.
//

import Foundation

struct SearchResponse: Decodable {
    let count: Int
    let result: [SearchResult]
}

struct SearchResult: Decodable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
