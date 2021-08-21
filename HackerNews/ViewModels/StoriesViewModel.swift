//
//  StoriesViewModel.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 2/3/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit

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
    var favoritesStore: FavoritesStore { get }
    var reloadData: () -> Void { get set }
    var didReceiveServiceError: (Error) -> Void { get set }
    var openStory: (Story) -> Void { get set }
    var openURL: (URL) -> Void { get set }
}


class StoriesViewModel: StoriesViewModelType, StoriesViewModelOutputs {

    var inputs: StoriesViewModelInputs { return self }

    var outputs: StoriesViewModelOutputs { return self }

    var stories: [Story] = [] {
        didSet {
            reloadData()
        }
    }

    let favoritesStore: FavoritesStore

    var reloadData: () -> Void = { }

    var didReceiveServiceError: (Error) -> Void = { _ in }

    var openStory: (Story) -> Void = { _ in }

    var openURL: (URL) -> Void = { _ in }

    let storyImageInfoStore: StoryImageInfoStore

    private let store: StoryStore

    private let type: StoryQueryType

    private var hasMore: Bool = false

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
        openStory(stories[indexPath.row])
    }

    func didSelectRowAt(_ indexPath: IndexPath) {
        let story = stories[indexPath.row]
        if let urlString = story.url, let url = URL(string: urlString) {
            outputs.openURL(url)
        } else {
            outputs.openStory(story)
        }
    }
    
}
