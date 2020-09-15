//
//  StoriesViewModel.swift
//  HackerNews
//
//  Created by Kenichi Fujita on 2/3/20.
//  Copyright © 2020 Kenichi Fujita. All rights reserved.
//

import UIKit

protocol StoriesViewModelDelegate: class {
    func storiesViewModelUpdated(_ viewModel: StoriesViewModelType)
}

protocol StoriesViewModelType: class {
    var stories: [Story] { get }
    var hasMore: Bool { get }
    var delegate: StoriesViewModelDelegate? { get set }
    var canShowInstruction: Bool { get }
    var favoritesStore: FavoritesStore { get }
    func load()
    func loadNext()
}


class StoriesViewModel: StoriesViewModelType {

    private(set) var stories: [Story] = [] {
        didSet {
            delegate?.storiesViewModelUpdated(self)
        }
    }
    weak var delegate: StoriesViewModelDelegate?
    let store: StoryStore
    let storyImageInfoStore: StoryImageInfoStore
    let type: StoryQueryType
    var hasMore: Bool = false
    var canShowInstruction: Bool {
      return false
    }
    var favoritesStore: FavoritesStore

    init(storyQueryType type: StoryQueryType, storyStore: StoryStore, storyImageInfoStore: StoryImageInfoStore, favoritesStore: FavoritesStore) {
        self.type = type
        self.store = storyStore
        self.storyImageInfoStore = storyImageInfoStore
        self.favoritesStore = favoritesStore
    }

    func load() {
        self.stories = []
        loadNext()
    }

    func loadNext() {
        hasMore = false
        store.stories(for: self.type, offset: self.stories.count, limit: 10) { (result) in
            if case .success(let stories) = result {
                self.stories.append(contentsOf: stories)
                if stories.count < 10 {
                    self.hasMore = false
                } else {
                    self.hasMore = true
                }
            }
        }
    }

}
