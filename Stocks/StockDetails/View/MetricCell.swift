//
//  MetricCell.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/22.
//

import UIKit

class MetricCell: UICollectionViewCell, Reusable {
    
    struct ViewModel {
        let name: String
        let value: String
    }
    
    // MARK: - UIElement
    
    private let nameLabel = UILabel {
        $0.textColor = .label
    }
    
    private let valueLabel = UILabel {
        $0.textColor = .secondaryLabel
    }
    
    // MARK: - AutoLayout
    
    private func setAutoLayout() {
        contentView.addSubviews(nameLabel, valueLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(3)
            make.top.bottom.equalTo(contentView)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel.snp.right).offset(3)
            make.top.bottom.equalTo(contentView)
            make.right.lessThanOrEqualTo(contentView).offset(5)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
    }
    
    // MARK: - Public
    
    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name + ": "
        valueLabel.text = viewModel.value
    }
    
    // MARK: - Private
    
}
