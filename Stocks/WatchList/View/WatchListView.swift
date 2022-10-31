//
//  WatchListView.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/28.
//

import UIKit

class WatchListView: UIView {

    // MARK: - Properties
    
    // MARK: - UIElement
    
    let tableView = UITableView {
        $0.backgroundColor = .systemBackground
        $0.register(cellType: WatchListTableViewCell.self)
    }
    
    // MARK: - AutoLayout
    
    private func setAutoLayout() {
        addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    // MARK: - Private
    
}
