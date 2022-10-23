//
//  StockChartView.swift
//  Stocks
//
//  Created by tomtung on 2022/8/27.
//

import UIKit
import Charts

class StockChartView: UIView {
    
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
        let fillColor: UIColor
    }
    
    // MARK: - Properties
    
    // MARK: - UIElements
    
    private let chartView = LineChartView {
        $0.pinchZoomEnabled = false
        $0.setScaleEnabled(true)
        $0.xAxis.enabled = false
        $0.legend.enabled = false
        $0.drawGridBackgroundEnabled = false
        $0.leftAxis.enabled = false
        $0.rightAxis.enabled = false
    }
    
    // MARK: - Autolayout
    
    private func setAutoLayout() {
        addSubview(chartView)
        
        chartView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    // MARK: - Lifecycle
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Methods
    
    func reset() {
        chartView.data = nil
    }
    
    func configure(with viewModel: ViewModel) {
        var entries = [ChartDataEntry]()
        
        for (index, value) in viewModel.data.enumerated() {
            entries.append(.init(x: Double(index), y: value))
        }
        
        chartView.rightAxis.enabled = viewModel.showAxis
        chartView.legend.enabled = viewModel.showLegend
        
        let dataSet = LineChartDataSet(entries: entries, label: "7 Days")
        dataSet.fillColor = viewModel.fillColor
        dataSet.drawFilledEnabled = true
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
    }
}
