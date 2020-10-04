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
    
    init(viewModel: StoriesViewModelType, title: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = title
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
        return tableView
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .systemGray
        label.text = "Swipe stories to the left to add to Favorites and favorite stories to appear here"
        label.textAlignment = .center
        return label
    }()
    
    let instructionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    override func loadView() {
        super.loadView()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
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
        refreshControl.addTarget(self, action: #selector(fetchItems), for: .valueChanged)
        tableView.delegate = self
        tableView.dataSource = self
        fetchItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = title
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.title = ""
    }
    
    @objc func fetchItems() {
        viewModel.load()
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let favoritesStore = viewModel.favoritesStore
        let story = viewModel.stories[indexPath.row]
        let title: String = favoritesStore.has(story: story.id) ? "Unfavorite" : "Favorite"

        let action = UIContextualAction(style: .destructive, title: title) { (action, view, completionHandler) in

            if title == "Favorite" {
                favoritesStore.add(storyId: story.id)
            } else {
                favoritesStore.remove(storyId: story.id)
            }
            if let cell = tableView.cellForRow(at: indexPath) as? StoryCell {
                cell.configure(with: story)
            }
            completionHandler(true)
        }
        action.backgroundColor = .systemTeal
        return UISwipeActionsConfiguration(actions: [action])
    }
        
    func showSafariViewController(for url: String) {
        
        guard let url = URL(string: url) else {
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1, viewModel.hasMore {
            viewModel.loadNext()
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
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        tableView.reloadData()
    }
    
}
