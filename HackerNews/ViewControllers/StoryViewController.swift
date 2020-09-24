//
//  StoryViewController.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 12/2/19.
//  Copyright © 2019 Kenichi Fujita. All rights reserved.
//

import UIKit
import SafariServices
import Kingfisher

class StoryViewController: UIViewController {
    private let story: Story
    private let api = APIClient()
    private var commentSections: [[Comment]] = []
    private var headerImage: UIImage?

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.register(StoryViewHeaderCell.self, forCellReuseIdentifier: "StoryViewHeaderCell")
        return tableView
    }()
    
    
    init(_ story: Story) {
        self.story = story
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint                      (equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint                 (equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint                   (equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint                  (equalTo: view.leadingAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        getComments(of: self.story)
        ogImage(story) { (image) in
            self.headerImage = image
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    private func getComments(of story: Story) {
        var commentsDict: [Int: [Comment]] = [:]
        api.comment(id: story.id) { (result) in
            if case .success(let comments) = result {
                for comment in comments {
                    commentsDict[comment.id] = comment.flatten
                    if commentsDict.count == comments.count {
                        self.commentSections = comments.compactMap { $0.id }.compactMap { commentsDict[$0] }.compactMap { $0.filter { $0.by != nil } }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func ogImage(_ story: Story, completionHandler: @escaping (UIImage?) -> Void) {
        guard let urlString = story.url, let url = URL(string: urlString) else {
            return completionHandler(nil)
        }
        StoryImageInfoStore.shared.ogImageURL(url: url) { (ogImageURL) in
            if let ogImageURL = ogImageURL {
                KingfisherManager.shared.retrieveImage(with: ogImageURL) { (result) in
                    if case .success(let value) = result {
                        completionHandler(value.image)
                    }
                }
            }
        }
    }
    
}

extension StoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return commentSections.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            return commentSections[section - 1].count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoryViewHeaderCell", for: indexPath)
            guard let storyViewHeaderCell = cell as? StoryViewHeaderCell else {
                return cell
            }
            storyViewHeaderCell.delegate = self
            storyViewHeaderCell.configureStory(with: story, image: headerImage)
            return storyViewHeaderCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            guard let commentCell = cell as? CommentCell else {
                return cell
            }
            let comment = self.commentSections[indexPath.section - 1][indexPath.row]
            commentCell.configure(with: comment)
            commentCell.delegate = self
            return commentCell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let topCell = tableView.indexPathForRow(at: CGPoint(x:0, y: tableView.contentOffset.y + tableView.adjustedContentInset.top))

        if topCell == nil || topCell == [0, 0] {
            self.title = ""
        } else {
            self.title = story.title
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension StoryViewController: StoryViewHeaderCellDelegate {
    
    func StoryViewHeaderCellHostButtonTapped(_ cell: StoryViewHeaderCell) {
        guard let urlString = self.story.url, let url = URL(string: urlString) else {
            return
        }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
    
}

extension StoryViewController: CommentCellDelegate {
    func commentCell(_ commentCell: CommentCell, linkTapped url: URL) {
        showSafariViewController(for: url)
    }
    
    private func showSafariViewController(for url: URL) {
        present(SFSafariViewController(url: url), animated: true)
    }
}
