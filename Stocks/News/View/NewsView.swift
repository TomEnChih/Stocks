//
//  NewsView.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/21.
//

import UIKit

class NewsView: UIView {

    // MARK: - UIElement
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .secondarySystemBackground
        tv.register(cellType: NewsStoryCell.self)
        tv.register(headerFooterViewType: NewsHeaderView.self)
        return tv
    }()
    
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
