//
//  NetworkManager.swift
//  Stocks
//
//  Created by Tom Tung on 2022/11/1.
//

import UIKit

final class NetworkManager {
    
    // MARK: - Properties
    
    let router = Router<StockApi>()
    static let environment: NetworkEnvironment = .qa
    static let shared = NetworkManager()
    
    private enum NetworkError: Error {
        case noDataReturned
    }
    
    // MARK: - Init
    
    private init() { }
    
    // MARK: - Public
    
    public func search(query: String,
                       completion: @escaping (Result<SearchResponse, Error> )->Void) {

        request(with: .search(query: query), expecting: SearchResponse.self, completion: completion)
    }

    public func news(for type: NewsStoryViewModel.`Type`,
                     compeletion: @escaping (Result<[NewsStory], Error>)->Void) {

        request(with: .companyNews(type: type), expecting: [NewsStory].self, completion: compeletion)
    }

    public func marketData(for symbol: String,
                           numberOfDays: TimeInterval = 7,
                           completion: @escaping (Result<MarketDataResponse, Error>) -> Void) {

        request(with: .marketData(symbol: symbol, numberOfDays: numberOfDays), expecting: MarketDataResponse.self, completion: completion)
    }

    public func financialMetrics(for symbol: String,
                                 completion: @escaping (Result<FinancialMetricsResponse, Error>) -> Void) {

        request(with: .financialMetrics(symbol: symbol), expecting: FinancialMetricsResponse.self, completion: completion)
    }
    
    // MARK: - Private
    
    private func request<T: Decodable>(with stockApi: StockApi,
                                       expecting: T.Type,
                                       completion: @escaping(Result<T,Error>)-> Void) {
        
        router.request(stockApi) { data, response, error in
            
            guard let data = data,
                  error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(NetworkError.noDataReturned))
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
    }
    
}
