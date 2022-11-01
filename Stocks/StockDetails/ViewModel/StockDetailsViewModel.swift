//
//  StockDetailsViewModel.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/24.
//

import Foundation

class StockDetailsViewModel {

    // MARK: - Properties

    let symbol: String
    let companyName: String
    // 股價資訊
    var candleStickData: [CandleStick]
    // 新聞資訊
    var stories = Dynamic([NewsStory]())
    //
    var metrics: Metrics?
    
    var metricViewModels = Dynamic([MetricCell.ViewModel]())
    
    var stockChartViewModel = Dynamic(StockChartView.ViewModel(data: [],
                                                               showLegend: true,
                                                               showAxis: true,
                                                               fillColor: .systemRed))
    

    // MARK: - Public
    
    var reloadDataClosure: (()->Void)?
    var updateRenderChartClosure: (()->Void)?
    
    var numberOfCells: Int {
        return stories.value.count
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> NewsStory {
        return stories.value[indexPath.row]
    }

    // MARK: - Init
    
    init(symbol: String, companyName: String, candleStickData: [CandleStick]) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        setUpBinding()
        fetchFinancialData()
        fetchNews()
    }

    // MARK: - Private
    
    private func setUpBinding() {
        
        stories.bind { [weak self] _ in
            self?.reloadDataClosure?()
        }
        
        metricViewModels.bind { [weak self] _ in
            self?.updateRenderChartClosure?()
        }
        
        stockChartViewModel.bind { [weak self] _ in
            self?.updateRenderChartClosure?()
        }
    }
    
    private func fetchFinancialData() {
        let group = DispatchGroup()
        
        // Fetch candle sticks if needed
        if candleStickData.isEmpty {
            group.enter()
            
            NetworkManager.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        // Fetch financial metrics
        group.enter()
        
        NetworkManager.shared.financialMetrics(for: symbol) { [weak self] result in
            
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metrics = metrics
                print(metrics)
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }
    
    private func renderChart() {

        if let metrics = metrics {
            var viewModels = [MetricCell.ViewModel]()
            viewModels.append(.init(name: "52W High", value: "\(metrics.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52L High", value: "\(metrics.AnnualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.TenDayAverageTradingVolume)"))
            metricViewModels.value = viewModels
        }

        let change = getChangePercentage(symbol: symbol, data: candleStickData)
        
        stockChartViewModel.value = StockChartView.ViewModel(data: candleStickData.reversed().map{ $0.close },
                                                             showLegend: true,
                                                             showAxis: true,
                                                             fillColor: change < 0 ? .systemGreen:.systemRed)
    }
    
    private func fetchNews() {
        
        NetworkManager.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories.value = stories
                    self?.reloadDataClosure?()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
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
}
