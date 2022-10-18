//
//  MarketDataResponse.swift
//  Stocks
//
//  Created by tomtung on 2022/8/25.
//

import Foundation

struct MarketDataResponse: Codable {
    let open: [Double]              //開盤價
    let close: [Double]             //收盤價
    let high: [Double]              //高價
    let low: [Double]               //低價
    let status: String              //Status of the response. ok 或 no_data
    let timestamps: [TimeInterval]  //時間
    
    enum CodingKeys: String, CodingKey {
        case open = "o"
        case low = "l"
        case close = "c"
        case high = "h"
        case status = "s"
        case timestamps = "t"
    }
    
    var candleSticks: [CandleStick] {
        var result = [CandleStick]()

        for index in 0..<open.count {
            result.append(.init(date: Date(timeIntervalSince1970: timestamps[index]),
                                high: high[index],
                                low: low[index],
                                open: open[index],
                                close: close[index])
            )
        }
        let sortedData = result.sorted { $0.date < $1.date }
        return sortedData
    }
}

struct CandleStick {
    let date: Date
    let high: Double
    let low: Double
    let open: Double
    let close: Double
}
