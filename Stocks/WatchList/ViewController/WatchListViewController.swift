//
//  WatchListViewController.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/7.
//

import UIKit
import FloatingPanel
import SnapKit

class WatchListViewController: UIViewController {
    
    private var searchTask: DispatchWorkItem?
    
    private var panel: FloatingPanelController?
    
    /// Model
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    /// ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private let tableView = UITableView {
        $0.backgroundColor = .systemBackground
        $0.register(cellType: WatchListTableViewCell.self)
    }
    
    private var observer: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTableView()
        fatchWatchlistData()
        setUpTitleView()
        setUpFloatingPanel()
        setUpObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private
    
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList,
                                                          object: nil,
                                                          queue: .main, using: { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fatchWatchlistData()
        })
    }
    
    private func fatchWatchlistData() {
        let symbols = PersistenceManager.shared.watchlist
        
        #warning("第一次使用")
        let group = DispatchGroup()
        
        for symbol in symbols where watchlistMap[symbol] == nil {
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
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    price: getlatestClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed: .systemGreen,
                    changePercentage: .percentage(from: changePercentage),
                    chartViewModel:.init(
                        data: candleSticks.reversed().map { $0.close },
                        showLegend: false,
                        showAxis: false
                    )
                )
            )
        }
        
        self.viewModels = viewModels
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
        panel.track(scrollView: vc.newsView.tableView)
    }
    
    private func setUpTitleView() {
        let titleView = WatchListTitleView(frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100))
        
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
              !query.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }
        
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
        
        let vc = StockDetailsViewController(symbol: searchResult.displaySymbol,
                                            companyName: searchResult.description)
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
        viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: WatchListTableViewCell.self)
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Open detail from selection
        let viewModel = viewModels[indexPath.row]
        let vc = StockDetailsViewController(symbol: viewModel.symbol,
                                            companyName: viewModel.companyName,
                                            candleStickData: watchlistMap[viewModel.symbol] ?? []
        )
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        // 不用调用cellForRow，仅仅需要调用heightForRow，这样效率最高。動畫效果更加同步、滑順
        tableView.beginUpdates()
        
        // Update persistence
        PersistenceManager.shared.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)
        
        // Update viewModels
        viewModels.remove(at: indexPath.row)
        
        // Deleta Row
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        tableView.endUpdates()
    }
}
