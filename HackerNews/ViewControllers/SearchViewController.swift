//
//  SearchViewController.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 3/23/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController {

    var viewModel: SearchViewModel
    var stories: [Story] = []
    
    init(viewModel: SearchViewModel, tabBarItemTitle: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        tabBarItem.title = tabBarItemTitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(StoryCell.self, forCellReuseIdentifier: "StoryCell")
        return tableView
    }()
    
    private let informationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        return label
    }()

    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    override func loadView() {
        super.loadView()

        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(informationLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            informationLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            informationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.searchController = searchController
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchBar.delegate = self
        viewModel.outputs.delegate = self
        viewModel.inputs.viewDidLoad()
    }
    
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath)
        guard let storyCell = cell as? StoryCell else {
            return cell
        }
        let story = self.stories[indexPath.row]
        storyCell.delegate = self
        storyCell.configure(with: story)
        return storyCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = self.stories[indexPath.row]
        if let url = story.url {
            showSafariViewController(for: url)
        } else {
            navigationController?.pushViewController(StoryViewController(story: story, favoritesStore: viewModel.favoritesStore), animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func showSafariViewController(for url: String) {
        guard let url = URL(string: url) else { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.endEditing(true)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.inputs.searchTextDidChange(searchText)
    }
}

extension SearchViewController: StoryCellDelegate {
    
    func storyCellCommentButtonTapped(_ cell: StoryCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let story = self.stories[indexPath.row]
        let storyViewController = StoryViewController(story: story, favoritesStore: viewModel.favoritesStore)
        navigationController?.pushViewController(storyViewController, animated: true)
    }
    
}

extension SearchViewController: SearchViewModelDelegate {

    func show(tableView shouldShowTableView: Bool, informationLabel shouldShowInformationLabel: Bool) {
        tableView.isHidden = !shouldShowTableView
        informationLabel.isHidden = !shouldShowInformationLabel
    }

    func update(informationText: String) {
        informationLabel.text = informationText
    }

    func reload(with stories: [Story]) {
        self.stories = stories
        tableView.reloadData()
    }

}
