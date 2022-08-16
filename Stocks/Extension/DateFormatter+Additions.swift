//
//  DateFormatter+Additions.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/13.
//

import Foundation

extension DateFormatter {
    
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
}
