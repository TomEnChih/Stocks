//
//  NewsHeaderView.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/12.
//

import UIKit

protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

class NewsHeaderView: UITableViewHeaderFooterView, Reusable {
    
    // MARK: - Properties
    
    static let preferredHeight: CGFloat = 70
    
    weak var delegate: NewsHeaderViewDelegate?
    
    // MARK: - UIElement
    
    private let label = UILabel {
        $0.font = .boldSystemFont(ofSize: 32)
    }
    
    private lazy var button = UIButton {
        $0.setTitle("+ Watchlist", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.backgroundColor = .systemBlue
        $0.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    // MARK: - AutoLayout
    
    private func setAutoLayout() {
        contentView.addSubviews(label, button)
        
        label.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(20)
        }
        
        button.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-10)
            make.width.equalTo(100)
        }
    }
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Public
    
    public func configure(with viewModel: NewsStoryViewModel.HeaderViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }
    
    // MARK: - Private
    
    @objc
    func didTapButton() {
        // Call delegate
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
    
    
}
