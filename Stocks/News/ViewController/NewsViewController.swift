//
//  NewsViewController.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/10.
//

import UIKit

class NewsViewController: UIViewController {

    enum `Type` {
        case topStories
        case cpmpany(symbol: String)
        
        var title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .cpmpany(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    // MARK: Properties
    
    private let type: Type
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.register(headerFooterViewType: NewsHeaderView.self)
        return tv
    }()
    
    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private
    
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchNews() {
        
    }
    
    
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(NewsHeaderView.self) else {
            return nil
        }
        header.configure(with: .init(title: self.type.title, shouldShowAddButton: true))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        70
    }
    
    
}
