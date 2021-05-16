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
    
    init(viewModel: StoriesViewModelType, tabBarTitle: String, tabBarImage: UIImage?) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        tabBarItem.title = tabBarTitle
        tabBarItem.image = tabBarImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let viewModel: StoriesViewModelType
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.systemBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(StoryCell.self, forCellReuseIdentifier: "StoryCell")
        tableView.isHidden = true
        return tableView
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .systemGray
        label.text = "You have no favorite stories"
        label.textAlignment = .center
        return label
    }()
    
    let instructionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()

    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),

            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        if viewModel.canShowInstruction {
            view.addSubview(instructionView)
            instructionView.addSubview(instructionLabel)
            
            NSLayoutConstraint.activate([
                instructionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                instructionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                instructionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                instructionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                
                instructionLabel.centerYAnchor.constraint(equalTo: instructionView.centerYAnchor),
                instructionLabel.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 100),
                instructionLabel.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -100)
            ])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        tableView.refreshControl = self.refreshControl
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.delegate = self
        tableView.dataSource = self

        viewModel.viewDidLoad()
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
        viewModel.didPullToRefresh()
    }
}


extension StoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath)
        guard let storyCell = cell as? StoryCell else {
            return cell
        }
        let story = viewModel.stories[indexPath.row]
        storyCell.delegate = self
        storyCell.configure(with: story)
        return storyCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = viewModel.stories[indexPath.row]
        if let url = story.url {
            showSafariViewController(for: url)
        } else {
            navigationController?.pushViewController(StoryViewController(story: story, favoritesStore: viewModel.favoritesStore), animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
        
    func showSafariViewController(for url: String) {
        guard let url = URL(string: url) else { return }
        present(SFSafariViewController(url: url), animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1, viewModel.hasMore {
            viewModel.lastCellWillDisplay()
        }
    }
    
}


extension StoriesViewController: StoryCellDelegate {
    
    func storyCellCommentButtonTapped(_ cell: StoryCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let story = viewModel.stories[indexPath.row]
        let storyViewController = StoryViewController(story: story, favoritesStore: viewModel.favoritesStore)
        navigationController?.pushViewController(storyViewController, animated: true)
    }
    
}


extension StoriesViewController: StoriesViewModelDelegate {
    
    func storiesViewModelUpdated(_ viewModel: StoriesViewModelType) {
        if viewModel.canShowInstruction {
            instructionView.isHidden = viewModel.stories.count != 0
        }
        self.tableView.reloadData()
        tableView.isHidden = false
        if refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
        activityIndicator.stopAnimating()
    }
    
}
