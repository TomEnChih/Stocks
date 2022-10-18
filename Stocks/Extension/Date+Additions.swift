//
//  Date+Additions.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/18.
//

import Foundation

extension Date {
    
    enum TimeUnit {
        case day(TimeInterval)
        case week(TimeInterval)
        case month(TimeInterval)
    }
    
    func prior(unit: TimeUnit) -> Self {
        let day: TimeInterval = 3600 * 24
        
        switch unit {
        case .day(let time):
            return self.addingTimeInterval(-(day * time))
        case .week(let time):
            return self.addingTimeInterval(-(day * 7 * time))
        case .month(let time):
            return self.addingTimeInterval(-(day * 30 * time))
        }
    }
    
    var intSince1970: Int {
        return Int(self.timeIntervalSince1970)
    }
}
