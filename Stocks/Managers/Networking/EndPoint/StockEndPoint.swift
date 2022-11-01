//
//  StockEndPoint.swift
//  Stocks
//
//  Created by Tom Tung on 2022/11/1.
//

import Foundation

enum NetworkEnvironment {
    case qa
    case production
}

enum StockApi {
    case search(query: String)
    case companyNews(type: NewsStoryViewModel.`Type`)
    case marketData(symbol: String,
                    numberOfDays: TimeInterval = 7)
    case financialMetrics(symbol: String)           //金融指標
}

extension StockApi: EndPointType {
    
    var environmentBaseURL: String {
        switch NetworkManager.environment {
        case .qa: return "https://finnhub.io/api/v1/"
        case .production: return "https://finnhub.io/api/v1/"
        }
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .search:
            return "search"
        case .companyNews(let type):
            switch type {
            case .topStories: return "news"
            case .company: return "company-news"
            }
        case .marketData:
            return "stock/candle"
        case .financialMetrics:
            return "stock/metric"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .search(let query):
            return .requestParameters(bodyParameters: nil,
                                      urlParameters: ["q":query,
                                                      "token":APIKeys.apiKey])
            
        case .companyNews(let type):
            switch type {
            case .topStories:
                return .requestParameters(bodyParameters: nil,
                                          urlParameters: ["category":"general",
                                                          "token":APIKeys.apiKey])
            case .company(let symbol):
                let today = Date()
                let oneMonthBack = today.prior(unit: .month(1))
                return .requestParameters(bodyParameters: nil,
                                          urlParameters: ["symbol":symbol,
                                                          "from":DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                                                          "to":DateFormatter.newsDateFormatter.string(from: today),
                                                          "token":APIKeys.apiKey])
            }
            
        case .marketData(let symbol, let numberOfDays):
            let today = Date().prior(unit: .day(1))
            let prior = today.prior(unit: .day(numberOfDays))
            return .requestParameters(bodyParameters: nil,
                                      urlParameters: ["symbol":symbol,
                                                      "resolution": "1",
                                                      "from": "\(prior.intSince1970)",
                                                      "to": "\(today.intSince1970)",
                                                      "token":APIKeys.apiKey])
        
        case .financialMetrics(let symbol):
            return .requestParameters(bodyParameters: nil,
                                      urlParameters: ["symbol": symbol,
                                                      "metric": "all",
                                                      "token":APIKeys.apiKey])
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
