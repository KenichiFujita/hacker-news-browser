//
//  StoriesDataSource.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 8/23/21.
//  Copyright © 2021 Kenichi Fujita. All rights reserved.
//

import UIKit

final class StoriesDataSource: NSObject, UITableViewDataSource {

    private var stories: [Story] = []

    private let section = 0

    func load(stories: [Story]) {
        self.stories = stories
    }

    func registerCellClass(tableView: UITableView) {
        tableView.register(StoryCell.self, forCellReuseIdentifier: "\(StoryCell.self)")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(StoryCell.self)", for: indexPath) as? StoryCell else {
            fatalError("Unrecognized cell")
        }
        cell.configure(with: stories[indexPath.row])
        return cell
    }

}
