//
//  WatchListTitleView.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/21.
//

import UIKit

class WatchListTitleView: UIView {

    // MARK: - Properties
    
    // MARK: - UIElement
    
    private let titleLabel = UILabel {
        $0.text = "Stocks"
        $0.textColor = .label
        $0.font = .systemFont(ofSize: 32, weight: .medium)
    }
    
    // MARK: - AutoLayout
    
    private func setAutoLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(10)
            make.bottom.equalTo(self)
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
