//
//  StockDetailsHeaderView.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/22.
//

import UIKit

class StockDetailsHeaderView: UIView {
    
    // MARK: - Properties
    
    private var metricViewModels: [MetricCell.ViewModel] = []

    // MARK: - UIElement
    
    private let chartView = StockChartView()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(cellType: MetricCell.self)
        cv.backgroundColor = .secondarySystemBackground
        return cv
    }()
    
    // MARK: - AutoLayout
    
    private func setAutoLayout() {
        addSubviews(chartView, collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(100)
        }
        
        chartView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(collectionView)
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setAutoLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    func configure(chartViewModel: StockChartView.ViewModel,
                   metricViewModels: [MetricCell.ViewModel]) {
        
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
    }
    
    // MARK: - Private

}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension StockDetailsHeaderView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as MetricCell
        let viewModel = metricViewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: 100/3)
    }
}
