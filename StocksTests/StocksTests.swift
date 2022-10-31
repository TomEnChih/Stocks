//
//  StocksTests.swift
//  StocksTests
//
//  Created by 董恩志 on 2022/8/7.
//

import XCTest
@testable import Stocks

class StocksTests: XCTestCase {
    
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func test_candleStick_data_conversion() {
        let doubles: [Double] = [149.35, 140.03, 140.02, 140.01, 140.02,
                                 140.03, 140.04, 140.05, 140.06, 144.8]
        let timestamps: [TimeInterval] = [1666515313,
                                             1666017420,
                                             1666017480,
                                             1666017540,
                                             1666017600,
                                             1666017660,
                                             1666017720,
                                             1666017780,
                                             1666017840,
                                             1666017900]
        
        let marketData = MarketDataResponse(open: doubles,
                                            close: doubles,
                                            high: doubles,
                                            low: doubles,
                                            status: "success",
                                            timestamps: timestamps)
        
        let diff = getChangePercentage(symbol: "test", data: marketData.candleSticks)
        let percentage: String = .percentage(from: diff)
        XCTAssertEqual(percentage, "-3.05%")
    }
    
    func getChangePercentage(symbol: String ,data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        let latestClose = data.first?.close
        let priorClose = data.first(where: {
            !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
        })?.close ?? data.last?.close   //若為同一天則取最後一項
        
        guard let latestClose = latestClose, let priorClose = priorClose else { return 0 }
        
        let diff = (priorClose/latestClose) - 1
        print("\(symbol): \(diff)%")
        return diff
    }
}
