//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/9.
//

import UIKit
import SafariServices

class StockDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]
    
    private let stockDetailsView = StockDetailsView()
    
    private var stories: [NewsStory] = []
    
    private var metrics: Metrics?
    
    // MARK: - Public
    
    // MARK: - Init
    
    init(symbol: String, companyName: String, candleStickData: [CandleStick] = []) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = companyName
        setUpView()
        setUpCloseButton()
        fetchFinancialData()
        fetchNews()
    }
    
    // MARK: - Private
    
    private func setUpView() {
        view.addSubview(stockDetailsView)
        stockDetailsView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        stockDetailsView.tableView.dataSource = self
        stockDetailsView.tableView.delegate = self
    }
    
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    @objc
    private func didTapClose() {
        dismiss(animated: true)
    }
    
    private func fetchFinancialData() {
        let group = DispatchGroup()
        
        // Fetch candle sticks if needed
        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
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
        
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            
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
        // Chart VM | FinancialMetricViewModel(s)
        let headerView = StockDetailsHeaderView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: (view.width * 0.7) + 100
            )
        )
        
//        headerView.backgroundColor = .
        
        var viewModels = [MetricCell.ViewModel]()
        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52L High", value: "\(metrics.AnnualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.TenDayAverageTradingVolume)"))
        }
        
        let change = getChangePercentage(symbol: symbol, data: candleStickData)
        headerView.configure(
            chartViewModel: .init(
                data: candleStickData.reversed().map{ $0.close },
                showLegend: true,
                showAxis: true,
                fillColor: change < 0 ? .systemRed:.systemGreen
            ),
            metricViewModels: viewModels
        )
        
        stockDetailsView.tableView.tableHeaderView = headerView
    }
    
    private func fetchNews() {
        APICaller.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.stockDetailsView.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    #warning("之後改寫")
    private func getChangePercentage(symbol: String ,data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close else {
                  return 0
              }
        
        #warning("會有浮點數誤差")
        let diff = 1 - (priorClose/latestClose)
//        print("\(symbol): Current: (\(latestDate): \(latestClose) | Prior: \(priorClose)")
        print("\(symbol): \(diff)%")
        return diff
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension StockDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as NewsStoryCell
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(NewsHeaderView.self)
        header?.delegate = self
        header?.configure(with: .init(title: symbol.uppercased(),
                                      shouldShowAddButton: !PersistenceManager.shared.watchlistContains(symbol: symbol)))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}


// MARK: - NewsHeaderViewDelegate

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        // Add to watchList
        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchlist(symbol: symbol, companyName: companyName)
        
        let alert = UIAlertController(title: "Added to Watchlist",
                                      message: "We've added \(companyName) to your watchlist.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
