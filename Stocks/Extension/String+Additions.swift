//
//  String+Additions.swift
//  Stocks
//
//  Created by tomtung on 2022/8/20.
//

import Foundation

extension String {
    
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
}
