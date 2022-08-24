//
//  APICaller.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/7.
//

import Foundation

final class APICaller {
    
    static let shared = APICaller()
    
    private struct Constants {
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    private init() { }
    
    // MARK: - Public
    
    // get stock info
    
    // search stocks
    public func search(query: String,
                       completion: @escaping (Result<SearchResponse, Error> )->Void) {
        
        #warning("不太懂")
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = url(for: .search, queryParams: ["q":safeQuery]) else { return }
        
        request(url: url, expecting: SearchResponse.self, completion: completion)
    }
    
    public func news(for type: NewsViewController.`Type`,
                     compeletion: @escaping (Result<[NewsStory], Error>)->Void) {
        
        switch type {
        case .topStories:
            let url = url(for: .topStories, queryParams: ["category":"general"])
            request(url: url, expecting: [NewsStory].self, completion: compeletion)
            
        case .cpmpany(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
            let url = url(for: .companyNews,
                             queryParams: ["symbol":symbol,
                                           "from":DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                                           "to":DateFormatter.newsDateFormatter.string(from: today)])
            request(url: url, expecting: [NewsStory].self, completion: compeletion)
         }
        
    }
    
    public func marketData(for symbol: String,
                           numberOfDays: TimeInterval = 7,
                           completion: @escaping (Result<MarketDataResponse, Error>) -> Void) {
        
        let today = Date().addingTimeInterval(-(Constants.day))
        let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
        let url = url(for: .marketData,
                         queryParams: ["symbol":symbol,
                                       "resolution": "1",
                                       "from": "\(prior.timeIntervalSince1970)",
                                       "to": "\(today.timeIntervalSince1970)"])
        request(url: url, expecting: MarketDataResponse.self, completion: completion)
    }
    
    // MARK: - Private
    
    private enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
    }
    
    private enum APIError: Error {
        case invalidUrl
        case noDataReturned
    }
    
    private func url(for endpoint: Endpoint,
                     queryParams: [String:String] = [:]) -> URL? {
        
        var urlString = Constants.baseUrl + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        // Add any parameters
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        // Add token
        queryItems.append(.init(name: "token", value: APIKeys.apiKey))
        
        // Convert queryItems to suffix string
        urlString += "?" + queryItems.map({ "\($0.name)=\($0.value ?? "")"}).joined(separator: "&")
        
        print("\n\(urlString)\n")
        
        return URL(string: urlString)
    }
    
    private func request<T: Decodable>(url: URL?,
                                       expecting: T.Type,
                                       completion: @escaping(Result<T,Error>) -> Void) {
        
        guard let url = url else {
            // Invalid url
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            
            guard let data = data,
                  error == nil else {
                      if let error = error {
                          completion(.failure(error))
                      } else {
                          completion(.failure(APIError.noDataReturned))
                      }
                      return
                  }
            
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
