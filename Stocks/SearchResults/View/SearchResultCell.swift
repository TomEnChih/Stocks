//
//  SearchResultCell.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/7.
//

import UIKit

class SearchResultCell: UITableViewCell, Reusable {
    
    // MARK: - UIElement
    
    // Symbol Label
    private let symbolLabel = UILabel {
        $0.font = .systemFont(ofSize: 15, weight: .medium)
        $0.textColor = .label
    }
    
    // Company Label
    private let nameLabel = UILabel {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .secondaryLabel
    }
    
    lazy var leadingStackView = UIStackView {
        $0.addArrangedSubviews(symbolLabel, nameLabel)
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 5
        $0.backgroundColor = .clear
    }
    
    // MARK: - AutoLayout
    
    private func setAutoLayout() {
        contentView.addSubviews(leadingStackView)
        
        leadingStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
            make.left.equalTo(separatorInset).offset(20)
        }
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
    }
    
    // MARK: - Public
    
    func configure(with model: SearchResult) {
        symbolLabel.text = model.symbol
        nameLabel.text = model.description
    }
    
    // MARK: - Private
    
}
