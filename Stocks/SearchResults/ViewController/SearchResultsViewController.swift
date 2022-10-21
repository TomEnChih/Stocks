//
//  SearchResultsViewController.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/7.
//

import UIKit

protocol SearchResultDelegate: AnyObject {
    func didSelect(searchResult: SearchResult)
}

class SearchResultsViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: SearchResultDelegate?
    
    private var results: [SearchResult] = []
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(cellType: SearchResultCell.self)
        tv.isHidden = true
        return tv
    }()
        
    // MARK: - Public
    
    public func update(with results: [SearchResult]) {
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }
    
    // MARK: - Init
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    // MARK: - Private
    
    private func setUpView() {
        view.backgroundColor = .rgb(0, 0, 0, alpha: 0.2)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as SearchResultCell
        let model = results[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = results[indexPath.row]
        delegate?.didSelect(searchResult: model)
    }
}
