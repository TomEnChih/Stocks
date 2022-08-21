//
//  Declarative.swift
//  Stocks
//
//  Created by tomtung on 2022/8/20.
//

import Foundation

protocol Declarative: AnyObject {
    init()
}

extension Declarative {
    
    init(configure: (Self)->Void) {
        self.init()
        configure(self)
    }
}

extension NSObject: Declarative { }
