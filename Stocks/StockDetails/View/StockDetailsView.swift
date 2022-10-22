//
//  StockDetailsView.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/21.
//

import UIKit

class StockDetailsView: UIView {

    // MARK: - UIElement
    
    let tableView = UITableView {
        $0.register(cellType: NewsStoryCell.self)
        $0.register(headerFooterViewType: NewsHeaderView.self)
        $0.backgroundColor = .clear
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
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    // MARK: - Private
    
}
