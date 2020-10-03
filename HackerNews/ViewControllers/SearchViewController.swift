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
    
    let api = APIClient()
    var viewModel: SearchViewModel
    var stories: [Story] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(viewModel: SearchViewModel, title: String) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.title = title
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
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .systemGray
        label.text = "Search stories and results to show up here"
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        return label
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .systemGray
        label.text = "No stories found"
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        return label
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .systemGray
        label.text = "Sorry. Something went wrong..."
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
        view.addSubview(instructionLabel)
        view.addSubview(emptyLabel)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            instructionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
            navigationController?.pushViewController(StoryViewController(story), animated: true)
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
        let storyViewController = StoryViewController(story)
        navigationController?.pushViewController(storyViewController, animated: true)
    }
    
}

extension SearchViewController: SearchViewModelDelegate {

    func show(tableView shouldShowTableView: Bool,
              instructionLabel shouldShowInstructionLabel: Bool,
              emptyLabel shouldShowEmptyLabel: Bool,
              errorLabel shouldShowErrorLabel: Bool) {
        tableView.isHidden = !shouldShowTableView
        instructionLabel.isHidden = !shouldShowInstructionLabel
        emptyLabel.isHidden = !shouldShowEmptyLabel
        errorLabel.isHidden = !shouldShowErrorLabel
    }

    func reload(with stories: [Story]) {
        self.stories = stories
        tableView.reloadData()
    }

}
