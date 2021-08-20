//
//  StoriesViewModel.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 2/3/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit
import SafariServices

protocol StoriesViewModelType: AnyObject {
    var inputs: StoriesViewModelInputs { get }
    var outputs: StoriesViewModelOutputs { get }
}

protocol StoriesViewModelInputs {
    func viewDidLoad()
    func didPullToRefresh()
    func lastCellWillDisplay()
    func storyCellCommentButtonTapped(at indexPath: IndexPath)
    func didSelectRowAt(_ indexPath: IndexPath)
}

 protocol StoriesViewModelOutputs: AnyObject {
    var stories: [Story] { get }
    var reloadData: () -> Void { get set }
    var didReceiveServiceError: (Error) -> Void { get set }
    var pushViewController: (StoryViewController) -> Void { get set }
    var presentViewController: (UIViewController) -> Void { get set }
}


class StoriesViewModel: StoriesViewModelType, StoriesViewModelOutputs {

    var inputs: StoriesViewModelInputs { return self }

    var outputs: StoriesViewModelOutputs { return self }

    var stories: [Story] = [] {
        didSet {
            reloadData()
        }
    }

    var reloadData: () -> Void = { }

    var didReceiveServiceError: (Error) -> Void = { _ in }

    var pushViewController: (StoryViewController) -> Void = { _ in }

    var presentViewController: (UIViewController) -> Void = { _ in }

    let storyImageInfoStore: StoryImageInfoStore

    private let store: StoryStore

    private let type: StoryQueryType

    private var hasMore: Bool = false

    private var favoritesStore: FavoritesStore

    init(storyQueryType type: StoryQueryType, storyStore: StoryStore, storyImageInfoStore: StoryImageInfoStore, favoritesStore: FavoritesStore) {
        self.type = type
        self.store = storyStore
        self.storyImageInfoStore = storyImageInfoStore
        self.favoritesStore = favoritesStore
    }

    private func load(offset: Int = 0) {
        hasMore = false
        store.stories(for: self.type, offset: offset, limit: 10) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let stories):
                if offset == 0 {
                    strongSelf.stories = stories
                } else {
                    strongSelf.stories.append(contentsOf: stories)
                }
                strongSelf.hasMore = stories.count == 10 ? true : false
            case .failure(let error):
                strongSelf.didReceiveServiceError(error)
            }
        }
    }

}

extension StoriesViewModel: StoriesViewModelInputs {

    func viewDidLoad() {
        load()
    }

    func didPullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.load()
        }
    }

    func lastCellWillDisplay() {
        if hasMore {
            load(offset: stories.count)
        }
    }

    func storyCellCommentButtonTapped(at indexPath: IndexPath) {
        pushViewController(StoryViewController(story: stories[indexPath.row], favoritesStore: favoritesStore))
    }

    func didSelectRowAt(_ indexPath: IndexPath) {
        let story = stories[indexPath.row]
        if let url = story.url, let url = URL(string: url) {
            presentViewController(SFSafariViewController(url: url))
        } else {
            pushViewController(StoryViewController(story: story, favoritesStore: favoritesStore))
        }
    }
    
}
