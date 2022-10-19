//
//  WatchListTableViewCell.swift
//  Stocks
//
//  Created by tomtung on 2022/8/26.
//

import UIKit

protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}

class WatchListTableViewCell: UITableViewCell, Reusable {
    
    // MARK: - Properties
    
    static let preferredHeight: CGFloat = 60
    
    weak var delegate: WatchListTableViewCellDelegate?
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String               // formatted
        let changeColor: UIColor        // red or green
        let changePercentage: String    // formatted
        let chartViewModel: StockChartView.ViewModel
    }
    
    // MARK: - UIElements
    
    // Symbol Label
    private let symbolLabel = UILabel {
        $0.font = .systemFont(ofSize: 15, weight: .medium)
    }
    
    // Company Label
    private let nameLabel = UILabel {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
    }
    
    // Price Label
    private let priceLabel = UILabel {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
    }
    
    // Change in Price Label
    private let changeLabel = UILabel {
        $0.textColor = .white
        $0.textAlignment = .right
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 6
    }
    
    private let miniChartView = StockChartView {
        $0.backgroundColor = .systemPink
        $0.clipsToBounds = true
    }
    
    lazy var leadingStackView = UIStackView {
        $0.addArrangedSubviews(symbolLabel, nameLabel)
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.backgroundColor = .clear
    }
    
    
    // MARK: - Autolayout
    
    private func setAutoLayout() {
        addSubviews(leadingStackView, miniChartView, priceLabel, changeLabel)
        
        leadingStackView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(separatorInset.left)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.left.equalTo(contentView.snp.right).offset(-WatchListViewController.maxChangeWidth)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom)
            make.left.equalTo(contentView.snp.right).offset(-WatchListViewController.maxChangeWidth)
            make.width.equalTo(priceLabel)
        }
        
        miniChartView.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.centerX)
            make.centerY.equalTo(contentView)
            make.width.equalTo(contentView).multipliedBy(0.3)
            make.height.equalTo(contentView).offset(-12)
        }
    }
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let currentWith = max(max(priceLabel.width, changeLabel.width) + 10, WatchListViewController.maxChangeWidth)
        
        if currentWith > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWith
            delegate?.didUpdateMaxWidth()
        }
        
        priceLabel.snp.updateConstraints { make in
            make.left.equalTo(contentView.snp.right).offset(-WatchListViewController.maxChangeWidth)
        }
        
        changeLabel.snp.updateConstraints { make in
            make.left.equalTo(contentView.snp.right).offset(-WatchListViewController.maxChangeWidth)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        // Configure chart
    }
    
}
