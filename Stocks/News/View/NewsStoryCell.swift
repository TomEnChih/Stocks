//
//  NewsStoryCell.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/13.
//

import UIKit

class NewsStoryCell: UITableViewCell, Reusable {
    
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with viewModel: NewsStory) {
        
    }
}
