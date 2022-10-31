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
    
    private var panel: FloatingPanelController?
    
    private var viewModel = WatchListViewModel()
    
    private let watchListView = WatchListView()
    
    private var observer: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpView()
        setUpTitleView()
        setUpFloatingPanel()
        setUpObserver()
        setUpBinding()
    }
    
    // MARK: - Private
    
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList,
                                                          object: nil,
                                                          queue: .main, using: { [weak self] _ in
            self?.viewModel.cellViewModels.value.removeAll()
            self?.viewModel.fatchWatchlistData()
        })
    }
    
    private func setUpView() {
        view.addSubview(watchListView)
        watchListView.tableView.delegate = self
        watchListView.tableView.dataSource = self
        
        watchListView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    private func setUpBinding() {
        viewModel.reloadDataClosure = { [weak self] in
            self?.watchListView.tableView.reloadData()
        }
    }
    
    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController()
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.delegate = self
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
        
        viewModel.searchStocks(query: query) { result in
            resultsVC.update(with: result)
        }
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
        viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: WatchListTableViewCell.self)
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Open detail from selection
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        let vc = StockDetailsViewController(symbol: cellViewModel.symbol,
                                            companyName: cellViewModel.companyName,
                                            candleStickData: viewModel.watchlistMap[cellViewModel.symbol] ?? []
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
        PersistenceManager.shared.removeFromWatchlist(symbol: viewModel.getCellViewModel(at: indexPath).symbol)
        
        // Update viewModels
        viewModel.cellViewModels.value.remove(at: indexPath.row)
        
        // Deleta Row
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        tableView.endUpdates()
    }
}
