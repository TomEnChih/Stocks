//
//  Formatter+Additions.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/13.
//

import Foundation

extension DateFormatter {
    
    static let newsDateFormatter = DateFormatter {
        $0.dateFormat = "YYYY-MM-dd"
    }
    
    static let prettyDateFormatter = DateFormatter {
        $0.dateStyle = .medium
    }
}


extension NumberFormatter {
    
    static let percentFormatter = NumberFormatter {
        $0.locale = .current
        $0.numberStyle = .percent
        $0.maximumFractionDigits = 2
    }
    
    static let numberFormatter = NumberFormatter {
        $0.locale = .current
        $0.numberStyle = .decimal   // 無條件進位
        $0.maximumFractionDigits = 2
    }
}
