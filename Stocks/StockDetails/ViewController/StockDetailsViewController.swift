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
    
    private let stockDetailsView = StockDetailsView()
    
    private let viewModel: StockDetailsViewModel
    
    // MARK: - Public
    
    // MARK: - Init
    
    init(symbol: String, companyName: String, candleStickData: [CandleStick] = []) {
        viewModel = StockDetailsViewModel(symbol: symbol,
                                          companyName: companyName,
                                          candleStickData: candleStickData)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = viewModel.companyName
        setUpView()
        setUpCloseButton()
        setUpBinding()
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
    
    private func setUpBinding() {
        
        viewModel.reloadDataClosure = { [weak self] in
            self?.stockDetailsView.tableView.reloadData()
        }
        
        viewModel.updateRenderChartClosure = { [weak self] in
            self?.renderChart()
        }
    }
    
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    @objc
    private func didTapClose() {
        dismiss(animated: true)
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
        
        headerView.configure(
            chartViewModel: viewModel.stockChartViewModel.value,
            metricViewModels: viewModel.metricViewModels.value
        )
        
        stockDetailsView.tableView.tableHeaderView = headerView
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension StockDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as NewsStoryCell
        let story = viewModel.getCellViewModel(at: indexPath)
        cell.configure(with: .init(model: story))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(NewsHeaderView.self)
        header?.delegate = self
        header?.configure(with: .init(title: viewModel.symbol.uppercased(),
                                      shouldShowAddButton: !PersistenceManager.shared.watchlistContains(symbol: viewModel.symbol)))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let story = viewModel.getCellViewModel(at: indexPath)
        guard let url = URL(string: story.url) else { return }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}


// MARK: - NewsHeaderViewDelegate

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        // Add to watchList
        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchlist(symbol: viewModel.symbol, companyName: viewModel.companyName)
        
        let alert = UIAlertController(title: "Added to Watchlist",
                                      message: "We've added \(viewModel.companyName) to your watchlist.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
