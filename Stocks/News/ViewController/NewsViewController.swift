//
//  NewsViewController.swift
//  Stocks
//
//  Created by 董恩志 on 2022/8/10.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    // MARK: - Properties
    
    let newsView = NewsView()
    
    private let viewModel: NewsStoryViewModel
    
    // MARK: - Init
    
    init(type: NewsStoryViewModel.`Type`) {
        self.viewModel = NewsStoryViewModel(type: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBinding()
    }
    
    // MARK: - Private
    
    private func setUpView() {
        view = newsView
        newsView.tableView.dataSource = self
        newsView.tableView.delegate = self
    }
    
    private func setUpBinding() {
        viewModel.reloadDataClosure = { [weak self] in
            self?.newsView.tableView.reloadData()
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
        viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: NewsStoryCell.self)
        let story = viewModel.getCellViewModel(at: indexPath)
        cell.configure(with: story)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(NewsHeaderView.self) else {
            return nil
        }
        header.configure(with: .init(title: viewModel.type.title, shouldShowAddButton: false))
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
        let story = viewModel.getCellViewModel(at: indexPath)
        guard let url = URL(string: story.url) else { return }
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
