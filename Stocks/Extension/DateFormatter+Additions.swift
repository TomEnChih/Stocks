//
//  DateFormatter+Additions.swift
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
