//
//  EndPointType.swift
//  Stocks
//
//  Created by Tom Tung on 2022/11/1.
//

import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}
