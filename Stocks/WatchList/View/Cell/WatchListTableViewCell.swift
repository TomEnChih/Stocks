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
        let chartViewModel: StockChartView.ViewModel
    }
    
    // MARK: - UIElements
    
    // Symbol Label
    private let symbolLabel = UILabel {
        $0.font = .systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .label
    }
    
    // Company Label
    private let nameLabel = UILabel {
        $0.font = .systemFont(ofSize: 15, weight: .semibold)
        $0.textColor = .secondaryLabel
    }
    
    // Price Label
    private let priceLabel = UILabel {
        $0.font = .systemFont(ofSize: 15, weight: .semibold)
        $0.textColor = .label
        $0.textAlignment = .right
    }
    
    // Change in Price Label
    private let changeLabel = UILabel {
        $0.textColor = .white
        $0.textAlignment = .right
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 3
    }
    
    private let miniChartView = StockChartView {
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = false
        $0.clipsToBounds = true
    }
    
    lazy var leadingStackView = UIStackView {
        $0.addArrangedSubviews(symbolLabel, nameLabel)
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.backgroundColor = .clear
        $0.spacing = 5
    }
    
    lazy var trailingStackView = UIStackView {
        $0.addArrangedSubviews(priceLabel, changeLabel)
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.backgroundColor = .clear
        $0.spacing = 5
    }
    
    
    // MARK: - Autolayout
    
    private func setAutoLayout() {
        addSubviews(leadingStackView, miniChartView, trailingStackView)
        
        leadingStackView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView.left).offset(10)
        }
        
        let width = 70
        
        trailingStackView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView.snp.right).offset(-(width+10))
            make.width.equalTo(width)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        
        miniChartView.snp.makeConstraints { make in
            make.right.equalTo(trailingStackView.snp.left).offset(-10)
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
        miniChartView.configure(with: viewModel.chartViewModel)
    }
    
}
