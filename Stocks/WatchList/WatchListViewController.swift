//
//  WatchListViewController.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/7.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    private var searchTask: DispatchWorkItem?
    
    private var panel: FloatingPanelController?
    
    /// Model
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    /// ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private let tableView = UITableView {
        $0.backgroundColor = .orange
//        $0.register(cellType: UITableViewCell.self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTableView()
        setUpWatchlistData()
        setUpTitleView()
        setUpFloatingPanel()
    }
    
    // MARK: - Private
    
    private func setUpWatchlistData() {
        let symbols = PersistenceManager.shared.watchlist
        
        #warning("第一次使用")
        let group = DispatchGroup()
        
        for symbol in symbols {
            group.enter()
            
            APICaller.shared.marketData(for: symbol) { [weak self] result in
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
            self?.tableView.reloadData()
        }
    }
    
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = getChangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(.init(symbol: symbol,
                                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                                    price: getlatestClosingPrice(from: candleSticks),
                                    changeColor: changePercentage < 0 ? .systemRed: .systemGreen, changePercentage: "\(changePercentage)"))
        }
        
        self.viewModels = viewModels
    }
    
    private func getChangePercentage(symbol: String ,data: [CandleStick]) -> Double {
        let priorDate = Date().addingTimeInterval(-((3600 * 24) * 2))
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  Calendar.current.isDate($0.date, inSameDayAs: priorDate)
              })?.close else {
                  return 0
              }
        
        print("\(symbol): Current: (\(data[0].date): \(latestClose) | Prior\(priorDate): \(priorClose)")
        
        return priorClose/latestClose
    }
    
    private func getlatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else { return "" }
        
        return "\(closingPrice)"
    }
    
    private func setUpTableView() {
        view.addSubviews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController()
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.delegate = self
        #warning("不太確定")
        panel.track(scrollView: vc.tableView)
    }
    
    private func setUpTitleView() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100))
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width-20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 32, weight: .medium)
        titleView.addSubview(label)
        
        navigationItem.titleView = titleView
    }
    
    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }

}


// MARK: - UISearchResultsUpdating

extension WatchListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        ///移除字串前後空白後不能為空
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                  return
              }
        
        // Cancel task
        self.searchTask?.cancel()
        
        // Task encapsulates work
        let task = DispatchWorkItem {
            // Call API to search
            APICaller.shared.search(query: query) { result in
                
                switch result {
                case .success(let response):
                    // Update results controller
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result)
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                    print(error)
                }
            }
        }
        
        searchTask = task
        #warning("第一次使用")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: task)
    }
}


//MARK: - SearchResultDelegate

extension WatchListViewController: SearchResultDelegate {
    
    func didSelect(searchResult: SearchResult) {
        // Present stock detail for given selection
        print("Did select: \(searchResult.displaySymbol)")
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        let vc = StockDetailsViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true, completion: nil)
    }
}


// MARK: - FloatingPanelControllerDelegate

extension WatchListViewController: FloatingPanelControllerDelegate {
     
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = (fpc.state == .full)
    }
    
}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension WatchListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        watchlistMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ui)
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Open detail from selection
    }
    
}
