//
//  NewsStoryCell.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/13.
//

import UIKit

class NewsStoryCell: UITableViewCell, Reusable {
    
    // MARK: - Properties
    
    static let preferredHeight: CGFloat = 140
    
    // MARK: - UIElements
    
    // Source
    private let sourceLabel = UILabel {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    // Headline
    private let headlineLabel = UILabel {
        $0.font = .systemFont(ofSize: 22, weight: .medium)
        $0.numberOfLines = 0
    }
    
    // Date
    private let dateLabel = UILabel {
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    // Image
    private let storyImageView = CustomImageView {
        $0.backgroundColor = .tertiarySystemBackground
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
    }
    
    // MARK: - Autolayout
    
    private func setAutoLayout() {
        contentView.addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
        
        storyImageView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-10)
            make.height.equalTo(contentView).multipliedBy(1/1.4)
            make.width.equalTo(contentView.snp.height).multipliedBy(1/1.4 * (700/538))
        }
        
        sourceLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(4)
            make.left.equalTo(contentView).offset(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(contentView).offset(-10)
            make.left.equalTo(sourceLabel)
            make.height.equalTo(14)
        }
        
        headlineLabel.snp.makeConstraints { make in
            make.top.equalTo(sourceLabel.snp.bottom).offset(5)
            make.bottom.lessThanOrEqualTo(dateLabel.snp.top).offset(-5)
            make.left.equalTo(sourceLabel)
            make.right.equalTo(storyImageView.snp.left).offset(-5)
        }
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setAutoLayout()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
    
    // MARK: - Methods
    
    func configure(with viewModel: NewsStoryViewModel.CellViewModel) {
        sourceLabel.text = viewModel.source
        headlineLabel.text = viewModel.headline
        dateLabel.text = viewModel.dateString
        storyImageView.loadingImage(viewModel.imageUrl)
    }
}
