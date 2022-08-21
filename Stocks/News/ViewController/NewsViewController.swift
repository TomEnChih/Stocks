//
//  NewsViewController.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/10.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {

    enum `Type` {
        case topStories
        case cpmpany(symbol: String)
        
        var title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .cpmpany(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    // MARK: Properties
    
    private let type: Type
    
    var stories = [NewsStory]()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.register(cellType: NewsStoryCell.self)
        tv.register(headerFooterViewType: NewsHeaderView.self)
        return tv
    }()
    
    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private
    
    private func setUpTable() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchNews() {
        APICaller.shared.news(for: type) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func open(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: NewsStoryCell.self)
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(NewsHeaderView.self) else {
            return nil
        }
        header.configure(with: .init(title: self.type.title, shouldShowAddButton: true))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        NewsStoryCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        NewsHeaderView.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            return
        }
        open(url: url)
    }
    
    private func presentFailedToOpenAlert() {
        let alert = UIAlertController(title: "Unable to open",
                                      message: "We were unable to open the article",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
