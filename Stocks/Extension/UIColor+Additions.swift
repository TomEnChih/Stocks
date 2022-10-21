//
//  UIColor+Additions.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/21.
//

import UIKit

extension UIColor {
    
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return .init(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
