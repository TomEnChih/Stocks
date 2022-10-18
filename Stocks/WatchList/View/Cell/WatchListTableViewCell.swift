//
//  WatchListTableViewCell.swift
//  Stocks
//
//  Created by tomtung on 2022/8/26.
//

import UIKit

class WatchListTableViewCell: UITableViewCell, Reusable {
    
    // MARK: - Properties
    
    static let preferredHeight: CGFloat = 60
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String               // formatted
        let changeColor: UIColor        // red or green
        let changePercentage: String    // formatted
        // let chartViewModel: StockChartView.ViewModel
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
        $0.font = .systemFont(ofSize: 15, weight: .regular)
    }
    
    private let miniChartView = StockChartView()
    
    
    // MARK: - Autolayout
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews(symbolLabel, nameLabel, miniChartView, priceLabel, changeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
//        miniChartView.reset()
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
