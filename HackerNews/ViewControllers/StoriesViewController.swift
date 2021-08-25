//
//  ViewController.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 11/17/19.
//  Copyright © 2019 Kenichi Fujita. All rights reserved.
//

import UIKit
import SafariServices

class StoriesViewController: UIViewController {

    private let viewModel: StoriesViewModelType
    private let dataSource = StoriesDataSource()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.estimatedRowHeight = 100
        return tableView
    }()

    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    init(viewModel: StoriesViewModelType, title: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.refreshControl = self.refreshControl
        dataSource.registerCellClass(tableView: tableView)
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        bind()

        viewModel.inputs.viewDidLoad()
    }

    func bind() {
        viewModel.outputs.reloadData = { [weak self] stories in
            guard let strongSelf = self else { return }
            strongSelf.dataSource.load(stories: stories)
            strongSelf.tableView.reloadData()
            if strongSelf.refreshControl.isRefreshing {
                strongSelf.refreshControl.endRefreshing()
            }
        }

        viewModel.outputs.didReceiveServiceError = { [weak self] error in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: "Network Error", message: "error", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            strongSelf.present(alert, animated: true, completion: nil)
        }

        viewModel.outputs.openURL = { [weak self] url in
            guard let strongSelf = self else { return }
            strongSelf.present(SFSafariViewController(url: url), animated: true)
        }

        viewModel.outputs.openStory = { [weak self] story in
            guard let strongSelf = self else { return }
            strongSelf.navigationController?.pushViewController(StoryViewController(story: story, favoritesStore: strongSelf.viewModel.outputs.favoritesStore), animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = title
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }
    
    @objc func didPullToRefresh() {
        viewModel.inputs.didPullToRefresh()
    }

}


extension StoriesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.inputs.didSelectRowAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            viewModel.inputs.lastCellWillDisplay()
        }
    }
    
}


extension StoriesViewController: StoryCellDelegate {
    
    func storyCellCommentButtonTapped(_ cell: StoryCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        viewModel.inputs.storyCellCommentButtonTapped(at: indexPath)
    }
    
}
