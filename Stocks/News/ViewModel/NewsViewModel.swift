//
//  NewsViewModel.swift
//  Stocks
//
//  Created by Tom Tung on 2022/10/21.
//

import Foundation

class NewsStoryViewModel {
    
    struct HeaderViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }
    
    struct CellViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageUrl: String
        let url: String
        
        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageUrl = model.image
            self.url = model.url
        }
    }
    
    enum `Type` {
        case topStories
        case company(symbol: String)
        
        var title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    // MARK: - Properties
    
    private var cellViewModels = Dynamic([CellViewModel]())
    
    // MARK: - Public
    
    let type: `Type`
    
    var reloadDataClosure: (()->Void)?
    
    var numberOfCells: Int {
        return cellViewModels.value.count
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> CellViewModel {
        return cellViewModels.value[indexPath.row]
    }
    
    // MARK: - Init
    
    init(type: `Type`) {
        self.type = type
        setUpBinding()
        fetchNews()
    }
    
    // MARK: - Private
    
    private func setUpBinding() {
        
        cellViewModels.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.reloadDataClosure?()
            }
        }
    }
    
    private func fetchNews() {
        
        NetworkManager.shared.news(for: type) { [weak self] result in
            
            switch result {
            case .success(let stories):
                
                for story in stories {
                    self?.cellViewModels.value.append(.init(model: story))
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
