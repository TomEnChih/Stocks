//
//  UIStackView+Additions.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/19.
//

import UIKit

extension UIStackView {
    
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            addArrangedSubview($0)
        }
    }
}
