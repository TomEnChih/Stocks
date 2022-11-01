//
//  WatchListViewModel.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/28.
//

import Foundation

class WatchListViewModel {
    
    // MARK: - Properties
    
    /// Model
    var watchlistMap: [String: [CandleStick]] = [:]
    
    /// ViewModels
    var cellViewModels = Dynamic([WatchListTableViewCell.ViewModel]())
    
    private var searchTask: DispatchWorkItem?
    
    // MARK: - Public
    
    var reloadDataClosure: (()->Void)?
    
    var numberOfCells: Int {
        return cellViewModels.value.count
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> WatchListTableViewCell.ViewModel {
        return cellViewModels.value[indexPath.row]
    }
    
    func fatchWatchlistData() {
        let symbols = PersistenceManager.shared.watchlist
        
        #warning("第一次使用")
        let group = DispatchGroup()
        
        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            
            NetworkManager.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.notify(queue: .main) {  [weak self] in
            self?.createViewModels()
            self?.reloadDataClosure?()
        }
    }
    
    func searchStocks(query: String, completion: @escaping ([SearchResult]) -> Void) {
        // Cancel task
        self.searchTask?.cancel()
        
        // Task encapsulates work
        let task = DispatchWorkItem {
            // Call API to search
            NetworkManager.shared.search(query: query) { result in
                
                switch result {
                case .success(let response):
                    // Update results controller
                    DispatchQueue.main.async {
                        completion(response.result)
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion([])
                    }
                    print(error)
                }
            }
        }
        
        searchTask = task
        #warning("第一次使用")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task)
    }
    
    // MARK: - Init
    
    init() {
        fatchWatchlistData()
        setBinding()
    }
    
    // MARK: - Private
    
    private func setBinding() {
        cellViewModels.bind { [weak self] _ in
            self?.reloadDataClosure?()
        }
        
    }
    
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = getChangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    price: getlatestClosingPrice(from: candleSticks),
                    changePercentage: changePercentage,
                    chartViewModel:.init(
                        data: candleSticks.reversed().map { $0.close },
                        showLegend: false,
                        showAxis: false,
                        fillColor: changePercentage < 0 ? .systemGreen: .red
                    )
                )
            )
        }
        
        self.cellViewModels.value = viewModels
    }
    
    #warning("之後改寫")
    private func getChangePercentage(symbol: String ,data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        let latestClose = data.first?.close
        let priorClose = data.first(where: {
            !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
        })?.close ?? data.last?.close   //若為同一天則取最後一項
        
        guard let latestClose = latestClose, let priorClose = priorClose else { return 0 }
        
        let diff = (priorClose/latestClose) - 1
        print("\(symbol): \(diff)%")
        return diff
    }
    
    private func getlatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else { return "" }
        return "\(closingPrice)"
    }
}
