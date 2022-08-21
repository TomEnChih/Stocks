//
//  NewsStoryCell.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/13.
//

import UIKit

class NewsStoryCell: UITableViewCell, Reusable {
    
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageUrl: String
        
        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageUrl = model.image
        }
    }
    
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
    
    private func setConstraints() {
        contentView.addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraints()
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = contentView.height/1.4
        storyImageView.frame = CGRect(x: contentView.width-imageSize-10,
                                      y: (contentView.height - imageSize)/2,
                                      width: imageSize,
                                      height: imageSize)
        
        let availableWidth: CGFloat = contentView.width-separatorInset.left-imageSize-15
        dateLabel.frame = CGRect(x: separatorInset.left,
                                 y: contentView.height-40,
                                 width: availableWidth,
                                 height: 40)
        
        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(x: separatorInset.left,
                                   y: 4,
                                   width: availableWidth,
                                   height: sourceLabel.height)
        
        headlineLabel.frame = CGRect(x: separatorInset.left,
                                 y: sourceLabel.bottom+5,
                                 width: availableWidth,
                                 height: contentView.height-sourceLabel.bottom-dateLabel.height-10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
    
    // MARK: - Methods
    
    func configure(with viewModel: ViewModel) {
        sourceLabel.text = viewModel.source
        headlineLabel.text = viewModel.headline
        dateLabel.text = viewModel.dateString
        storyImageView.loadingImage(viewModel.imageUrl)
    }
}
