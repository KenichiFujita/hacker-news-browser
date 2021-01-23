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
    func viewDidLoad()
    func didPullToRefresh()
    func lastCellWillDisplay()
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

    func viewDidLoad() {
        load()
    }

    func didPullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.load()
        }
    }

    func lastCellWillDisplay() {
        load(offset: stories.count)
    }

    private func load(offset: Int = 0) {
        hasMore = false
        store.stories(for: self.type,
                      offset: offset,
                      limit: 10) { [weak self] (result) in
            guard let strongSelf = self else { return }
            if case .success(let stories) = result {
                if offset == 0 {
                    strongSelf.stories = stories
                } else {
                    strongSelf.stories.append(contentsOf: stories)
                }
                if stories.count < 10 {
                    strongSelf.hasMore = false
                } else {
                    strongSelf.hasMore = true
                }
            }
        }
    }

}
